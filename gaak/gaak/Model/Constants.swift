//
//  Constants.swift
//  gaak
//
//  Created by Ted Kim on 2020/09/24.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import Foundation
import UIKit

enum DeviceInputType: Int {
    case back = 1
    case front
}

// 카메라 뷰에 담길 촬영 포토 사이즈를 위한 strcut
struct CameraViewPhotoSize {
    var width: CGFloat
    var height: CGFloat
}

// camera 관련
struct CameraRelatedCoreImageResource{
    var pixelBuffer: CVImageBuffer? = nil
    var ciImage: CIImage? = nil
    var cgImage: CGImage? = nil
    
}

// 카메라 뷰에서 포토앨범, 카메라 모드인지 구분하기 위한 enum
enum AddPhotoMode {
    case photoLibrary
    case camera
}

struct ScreenType {
    static let width: [CGFloat] = [0.0, 1080.0, 720.0]
    
    enum Ratio: Int {
        case square = 0
        case retangle
        case full
        
    }
    
    static func numberOfRatioType() -> Int {
        return 3
    }
    
    static func photoWidthByDeviceInput(type deviceInput: Int) -> CGFloat {
        switch deviceInput {
        case DeviceInputType.back.rawValue:
            return ScreenType.width[deviceInput]
        case DeviceInputType.front.rawValue:
            return ScreenType.width[deviceInput]
        default:
            fatalError()
        }
    }
    
    static func photoHeightByAspectScreenRatio(_ deviceType: Int, ratioType: Int ) -> CGFloat {
        
        switch ratioType {
        case Ratio.square.rawValue:
            return ScreenType.width[deviceType]
        case Ratio.retangle.rawValue:
            return (ScreenType.width[deviceType] * 4) / 3
        case Ratio.full.rawValue:
            return (ScreenType.width[deviceType] * 16) / 9
        default:
            fatalError()
            
        }
    }
    
    static func getCGRectPreiewImageView(target rect : CGRect, yMargin: CGFloat, ratioType: Int) -> CGRect {
        
        switch ratioType {
        case Ratio.square.rawValue:
            return CGRect(x: 0, y: (yMargin * 2), width: rect.width, height: rect.width)
        case Ratio.retangle.rawValue:
            return CGRect(x: 0, y: 0, width: rect.width, height: (rect.width * 4) / 3)
        case Ratio.full.rawValue:
            return CGRect(x: 0, y: 0, width: rect.width, height: (rect.width * 16) / 9)
        default:
            fatalError()
        }
    }
}
