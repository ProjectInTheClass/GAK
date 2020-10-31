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

class NewCIRenderer: FilterRenderer {
    
    var description: String = "New (Core Image)"
    
    var isPrepared = false
    
    private var ciContext: CIContext?
    
    private var newFilter: CIFilter?
    
    private var outputColorSpace: CGColorSpace?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    /// - Tag: FilterCoreImageNew
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        (outputPixelBufferPool,
         outputColorSpace,
         outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                             outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        inputFormatDescription = formatDescription
        ciContext = CIContext()
        newFilter = CIFilter(name: "CIColorMatrix")
        newFilter!.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        isPrepared = true
    }
    
    func reset() {
        ciContext = nil
        newFilter = nil
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard let newFilter = newFilter,
            let ciContext = ciContext,
            isPrepared else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
        
        let sourceImage = CIImage(cvImageBuffer: pixelBuffer)
        newFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        guard let filteredImage = newFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("CIFilter failed to render image")
            return nil
        }
        
        var pbuf: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
        guard let outputPixelBuffer = pbuf else {
            print("Allocation failure")
            return nil
        }
        
        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
        ciContext.render(filteredImage, to: outputPixelBuffer, bounds: filteredImage.extent, colorSpace: outputColorSpace)
        return outputPixelBuffer
    }
}
