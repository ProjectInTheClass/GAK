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
