//
//  NewCIRenderer.swift
//  AVCamFilter
//
//  Created by KIMHYEJUNG on 2020/10/11.
//  Copyright © 2020 Apple. All rights reserved.
//

import CoreMedia
import CoreVideo
import CoreImage

class LayeredCIRenderer: FilterRenderer {
    
    var description: String = "New (Core Image)"
    
    var isPrepared = false
    
    private var ciContext: CIContext?
    
    private var mySepiaFilter: CIFilter?
    private var myBloomFilter: CIFilter?
    
    private var outputColorSpace: CGColorSpace?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    /// - Tag: FilterCoreImageNew
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        // 필터 사용하기 전에 초기화
        reset()
        
        // 우리가 이미지를 어떤 형태로 가공해야할지 정보 저장하는것. 자세한건 몰라도됨
        (outputPixelBufferPool,
         outputColorSpace,
         outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                             outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        
        // 인풋 이미지가 어떤 형태일지 알려준다!
        inputFormatDescription = formatDescription
        
        // CIContext() 라는 건 우리가 CIImage에다가 CIFilter를 적용시키고 싶을 때 사용하는 것
        // 그래서 필수!! 근데 폰의 리소스(cpu, ram) 등 많이 잡아먹으니깐 필터 사용 전에 딱 한번만 만들고 필터 끝나면 없애주고
        ciContext = CIContext()

        // mySepiaFilter: 세피아 필터! 얘는 애플에서 미리 만들어놓은 CIFilter 중 한 개
        // 이렇게 미리 만들어놓은 필터들은 CIFilter(name: 이름) 형태로 가져온다고 한다.
        mySepiaFilter = CIFilter(name: "CISepiaTone")
        // mySepiaFilter.setValue ==> 세피아필터 "의" 값을 정한다!
        // setValue(???, forkey: XXX) 형태로 우리가 원하는 값 지정 가능. 여기선 intensity(강도)
        mySepiaFilter!.setValue(1, forKey: kCIInputIntensityKey)
        
        myBloomFilter = CIFilter(name: "CIBloom")
        myBloomFilter!.setValue(1, forKey: kCIInputIntensityKey)
        // 여기선 블룸필터의 radius 값 지정해줌!
        myBloomFilter!.setValue(10, forKey: kCIInputRadiusKey)

        // 이제 필터 사용 준비 끗! 이라고 마킹하는 용도
        isPrepared = true
    }
    
    func reset() {
        ciContext = nil
        mySepiaFilter = nil
        myBloomFilter = nil
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    // 실제로 렌더 -> 필터를 적용해서 이미지를 만들어내는 함수
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        // guard (something, somethingg, ... ) else { ... }
        // 가드! 이 값들(something, smethingg, ...)이 다 존재하는지 확인하는것
        // 우리가 필터를 적용하고 싶은데, 필터가 존재하지 않는다면???? 하면 안되니깐 바로 fail하고 리턴
        guard let sepiaFilter = mySepiaFilter,
            let bloomFilter = myBloomFilter,
            let ciContext = ciContext,
            isPrepared else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
        
        // 외부에서 이 필터를 사용할때, 이미지 "버퍼"라는걸 주는데, 우리는 그걸 CIImage로 변경해서 source image로 사용
        // 왜냐하면, CIFilter는 CIImage에만 적용시킬 수 있는 물건이기 때문
        let sourceImage = CIImage(cvImageBuffer: pixelBuffer)
        
        // sepia filter의 값 지정: 여기선 "인풋 이미지", 즉 실제로 필터를 적용시킬 그 CIImage를 지정해주는 것
        // 저어어어 위에 초기화 하는 과정에서 이걸 지정 안해준 이유?
        //.  왜냐하면!!! 대상 이미지는 계속 바뀔 수 있으니깐!!!! (영상모드이거나, 다른 이미지 등)
        sepiaFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // filteredImage1 은 sepiaFilter를 적용해서 나온 OutputImage를 가져온것. (forkey: kCIOutputImageKey)
        // 여기서 filteredImage1 은 아직까지 CIImage 타입인것을 유의!!! 사용자가 UI로 보려면 마지막 렌더링 과정 필요
        let filteredImage1 = sepiaFilter.value(forKey: kCIOutputImageKey) as? CIImage
        // guard!!!! -> 이거는 실제 sourceImage가 존재하는가 검사하는것! source Image가 없으면 필터링 할 것도 없으니 오류 ==> 리턴
        guard (filteredImage1 != nil) else {
            print("CIFilter failed to render image")
            return nil
        }
        
        // 위에 sepia처럼 똑같이 필터 적용시키는 과정. 이때 input이 뭔지 잘 살펴봐야함
        bloomFilter.setValue(filteredImage1, forKey: kCIInputImageKey)
        guard let filteredImage2 = bloomFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("CIFilter failed to render image")
            return nil
        }
        
        // 이미지를 메모리에 저장하기 위해 버퍼를 할당받는다. 할당 실패 시 에러
        var pbuf: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
        guard let outputPixelBuffer = pbuf else {
            print("Allocation failure")
            return nil
        }
        
        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
        ciContext.render(filteredImage2, to: outputPixelBuffer, bounds: filteredImage2.extent, colorSpace: outputColorSpace)
        return outputPixelBuffer
    }
}
