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
    
    
    //MARK: 카메라 전후 전환 icon
    func updateSwitchCameraIcon(position: AVCaptureDevice.Position) {
        // TODO: Update ICON
        switch position {
        case .front:
            let image = #imageLiteral(resourceName: "ic_camera_front")
            switchButton.setImage(image, for: .normal)
        case .back:
            let image = #imageLiteral(resourceName: "ic_camera_rear")
            switchButton.setImage(image, for: .normal)
        default:
            break
        }
    }
    //MARK: 카메라 전후 전환 func
    @IBAction func switchCamera(sender: Any) {
        // TODO: 카메라는 2개 이상이어야함
        guard videoDeviceDiscoverySession.devices.count > 1 else { return }
        
        // TODO: 반대 카메라 찾아서 재설정
        // - 반대 카메라 찾고
        // - 새로운 디바이스를 가지고 세션을 업데이트
        // - 카메라 전환 토글 버튼 업데이트
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            self.currentPosition = currentVideoDevice.position
            let isFront = self.currentPosition == .front
            // isFront이면 back에 있는걸, front가 아니면 front를 -> prefferedPosition
            let preferredPosition: AVCaptureDevice.Position = isFront ? .back : .front
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice?
            
            newVideoDevice = devices.first(where: { device in
                return preferredPosition == device.position
            })
            // -> 지금까지는 새로운 카메라를 찾음.
            
            // update capture session
            if let newDevice = newVideoDevice {
                
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
                    self.captureSession.beginConfiguration()
                    self.captureSession.removeInput(self.videoDeviceInput)
                    
                    // 새로 찾은 videoDeviceInput을 넣을 수 있으면 // 새로운 디바이스 인풋을 넣음
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else { // 아니면 그냥 원래 있던거 다시 넣고
                        self.captureSession.addInput(self.videoDeviceInput) // 이 조건문 다시보기
                    }
                    self.captureSession.commitConfiguration()
                    
                    // 카메라 전환 토글 버튼 업데이트
                    // UI관련 작업은 Main Queue에서 수행되어야 함
                    // 카메라 기능과 충돌이 생기면 안 되기 때문
                    DispatchQueue.main.async {
                        self.updateSwitchCameraIcon(position: preferredPosition)
                    }
                    
                } catch let error {
                    print("error occured while creating device input: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    //MARK: 더보기 func
    @IBAction func seeMore(_ sender: Any) {
        // 시작할 땐 히든 -> setupUI()
        // 이 버튼 누르면 다시 보임.
        if(moreView.isHidden) {
            // 가려져있으면, 켜주고
            moreView.isHidden = false
            moreView.alpha = 1
        }
        // + 아무데나 다른 곳을 누르면 사라짐. -> view tap gesture recognizer에서 구현해야함.
    }
    
    
    @IBAction func returnToMain(_ sender: Any) {
        // 더보기 창 꺼주기
        if (!moreView.isHidden) {
            // 켜져있으면, 꺼주고
            moreView.isHidden = true
        }
        
    }
}
