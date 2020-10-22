//
//  PreviewView.swift
//  gaak
//
//  Created by Ted Kim on 2020/09/14.
//  Copyright © 2020 Ted Kim. All rights reserved.
//
// 이 소스는 Apple Docs Sample Code 에서 가져옴
/* https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app */

import UIKit
import AVFoundation

class PreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {

        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        
        /// 도대체 왜 이 부분이 호출되는 순간(촬영버튼)에는 잘 적용돼서 저장도 잘 되는데, 정작 previewView에서는 왜 안 되는걸까?
        //layer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        //layer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        /// 그냥 미리보기 상태에서는 적용이 잘 안 되냐
        
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
        
    }
    
    // MARK: UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
