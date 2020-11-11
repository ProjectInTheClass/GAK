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


// 내가 만든 커스텀컬러
struct CustomColor {
    static func uiColor(_ color: String) -> UIColor {
        switch color {
        case "black":
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            
        case "clear":
            return UIColor(white: 1, alpha: 0)
            
        default:
            print("error in CustomColor")
            fatalError()
        }
    }
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

struct Setting {
    var content: String
    init(content: String) {
        self.content = content
    }
}

enum TopAlert: String {
    case On_Pin = "현재 각도로 고정되었습니다."
    case no_Pin = "각도 고정이 해제되었습니다."
}
