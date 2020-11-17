//
//  ImageExtension.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/02.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit

extension UIImage {
    
    // 이미지 회전
    func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degrees.toRadians());
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap = UIGraphicsGetCurrentContext() {
            
            bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            
            //   // Rotate the image context
            bitmap.rotate(by: degrees.toRadians())
            
            // Now, draw the rotated/scaled image into the context
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            if let cgImage = self.cgImage {
                bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            }
            
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { debugPrint("Failed to rotate image. Returning the same as input..."); return self }
            UIGraphicsEndImageContext()
            
            return newImage
        }else {
            debugPrint("Failed to create graphics context. Returning the same as input...")
            return self
        }
        
    }
    
    // target의 정한 사이즈 만큼 resize
    func resizeImage(targetSize: CGSize) -> UIImage {
        
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            
        } else {
            
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        
        let rect =  CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        //  CGRect 만큼 draw
        self.draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    
    
    // image를 1:1 비율로 crop
    func cropToSquareImage() -> UIImage{
        
        var cropRect: CGRect?
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        
        if imageWidth < imageHeight {
            // Potrait mode
            print("Potrait")
            cropRect = CGRect(x: 0.0, y: (imageHeight - imageWidth) / 2.0, width: imageWidth, height: imageWidth)
        } else if imageWidth > imageHeight{
            // Landscape mode
            print("Landscape")
            cropRect = CGRect(x: (imageWidth - imageHeight) / 2.0, y: 0.0, width: imageHeight, height: imageHeight)
        } else {
            print("self")

            return self
        }
        
        // Draw neew image in current graphics context
        
        guard let rect: CGRect = cropRect else {
            return UIImage()
        }
        
        return UIImage.init(cgImage: (self.cgImage?.cropping(to: rect))!)
    }
    
    // image에 fliter 적용하는 메소드
    func applyFilter(type filterName: String) -> UIImage{
        
        var resultImage:UIImage = self
        
        let originalOrientation: UIImage.Orientation = self.imageOrientation
        
        guard let image = resultImage.cgImage  else {
            return self
        }
        
        /*
         
         OpenGL ES는 하드웨어 가속 2D 및 3D 그래픽 렌더링을위한 C 기반 인터페이스를 제공합니다. iOS의 OpenGL ES 프레임 워크 (OpenGLES.framework)는 OpenGL ES 사양의 버전 1.1, 2.0 및 3.0 구현을 제공합니다.
         
         EAGL penGL ES 용 플랫폼 별 API
         the platform-specific APIs for OpenGL ES on iOS devices,
         
         */
        
        let context = CIContext(options: nil)
        
        let ciImage = CIImage(cgImage: image)
        
        if let filter = CIFilter(name: filterName) {
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                
                /*
                 scale : The scale factor to assume when interpreting the image data. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the size property.
                 */
                resultImage = UIImage(cgImage: context.createCGImage(output, from: output.extent)!, scale: 1, orientation: originalOrientation)
            }
            
        }
        
        return resultImage
    }
    
    
    // imageOrientation을 set
    func fixOrientationOfImage() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi)
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            
        default:
            context.draw(self.cgImage!, in: CGRect(origin: .zero, size: self.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    
    
    
}
public extension CGFloat {
    
    func toRadians() -> CGFloat {
        //return self / (180 * .pi)
        return self * .pi / 180
    }
    
    func toDegrees() -> CGFloat {
        //return self * (180 * .pi)
        return self * .pi * 180
    }
}
