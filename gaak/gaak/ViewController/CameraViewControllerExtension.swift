//
//  CameraViewControllerExtension.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/02.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension CameraViewController {
    
    // MARK:- Get Screen Ratio
    // AVCaptureDevice 종류와 선택한 스크린 사이즈 비율에 맞게 PreviewImageView Frame 변경
    /// 이 함수는 호출되지만, 함수에서 변경된 contants는 사용되지 않음.
    /// 나중에 시간있으면 코드정리할 때, 이 함수를 사용해여 객체지향프로그래밍을 구현할 것.
    /// -> 귀찮아서 사용 안 하는중...
    func getSizeByScreenRatio(with currentPosition: AVCaptureDevice.Position, at screenRatioStatus: Int){
        var photoWidth: CGFloat?
        var photoHeight: CGFloat?
        
        photoWidth = ScreenType.photoWidthByDeviceInput(type: currentPosition.rawValue)
        photoHeight = ScreenType.photoHeightByAspectScreenRatio(currentPosition.rawValue, ratioType: screenRatioStatus)
        
        rectOfpreviewImage = ScreenType.getCGRectPreiewImageView(target: UIScreen.main.bounds, yMargin: settingToolbar.frame.height, ratioType: screenRatioStatus)
        
        
        if let photoWidth = photoWidth, let photoHeight = photoHeight{
            cameraViewPhotoSize = CameraViewPhotoSize(width: photoWidth, height: photoHeight)
        }
    }
    
    
    // MARK: - 라이브러리에 저장
    // 사진 저장할 때 화면비에 맞게 잘라서 저장해주는 함수
    /* 지금은 너무 코드가 더러움... 보기좋게 Constants를 만듥 것!! */
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        // 여기부터 // 더러워지기 시작 // 아랫부분 수정할 것
        var croppedImage: UIImage = image
        
        if( screenRatioSwitchedStatus == 0 ) { // 1:1 비율일 때
            
            let rectRatio = CGRect(x: 0, y: image.size.height - image.size.width, width: image.size.width, height: image.size.width)
                        
            croppedImage = cropImage2(image: image, rect: rectRatio, scale: 1.0) ?? image
        }
        else if( screenRatioSwitchedStatus == 1 ) {
            
            let rectRatio = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width*4.0/3.0)
                        
            croppedImage = cropImage2(image: image, rect: rectRatio, scale: 1.0) ?? image
        }
        else {
            
            let rectRatio = CGRect(x: (image.size.width)/(4.0)/(2.0), y: 0, width: (image.size.height)*(9.0)/(16.0), height: image.size.height)
            
            croppedImage = cropImage2(image: image, rect: rectRatio, scale: 1.0) ?? image
        }
        // cripImage2 함수도 같이 정리할 것.
        self.savePhotoLibrary(image: croppedImage)
    }
    
    func cropImage2 (image : UIImage, rect : CGRect, scale : CGFloat)-> UIImage? {
        UIGraphicsBeginImageContextWithOptions (
            CGSize (width : rect.size.width / scale, height : rect.size.height / scale), true, 0.0)
        image.draw (at : CGPoint (x : -rect.origin.x / scale, y : -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext ()
        return croppedImage
    }
    
    
    
}
