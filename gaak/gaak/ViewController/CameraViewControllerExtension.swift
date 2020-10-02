//
//  CameraViewControllerExtension.swift
//  gaak
//
//  Created by Ted Kim on 2020/09/29.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreImage

extension CameraViewController {
    
    // MARK:- Setup and configure UI
    func setUpCamera() {
        
        /* 카메라를 셋업하지 않아도 될 경우가 발생하면 본 주석 해제 후 적절히 수정
        // 포토 라이브러리에서 이미지를 가져온 경우 return
        if photoMode == AddPhotoMode.photoLibrary {
            changeUIWhenPickImageFromPhotoAblum()
            return
        }
        switchOfCameraBarButtonItem.isEnabled = true
        flashOfCameraBarButtonItem.isEnabled = true
        */
        
        let deviceSession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        if let session = captureSession {
            for discoveredDevice in (deviceSession.devices){
                
                if (discoveredDevice.position == cameraPosition) {
                    captureDevice = discoveredDevice // device를 세팅
                    
                    session.sessionPreset = .photo
                    /*if cameraPosition == .back {
                        session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                    } else if cameraPosition == .front {
                        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
                    } 화질은 일단 앞뒤구분 없이 걍 통일함*/
                    
                    session.beginConfiguration()
                    
                    do{
                        let input = try AVCaptureDeviceInput(device: discoveredDevice)
                        
                        if session.canAddInput(input){
                            session.addInput(input)
                            
                            guard let photoOutput = self.photoOutput else {
                                print("Error on photoOutput: \(String(describing: self.photoOutput))")
                                return}
                            guard let videoDataOutput = self.videoDataOutput else {
                                print("Error on videoDataOutput: \(String(describing: self.videoDataOutput))")
                                return}
                            
                            if session.canAddOutput(photoOutput){
                                if session.canAddOutput(photoOutput),
                                   session.canAddOutput(videoDataOutput){
                                    
                                    session.addOutput(photoOutput)
                                    
                                    let videoOutput = videoDataOutput
                                    
                                    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                                    session.addOutput(videoOutput)
                                    
                                    session.startRunning()
                                }
                            }
                        }
                    
                    }
                    catch let avCaptureError {
                        print(avCaptureError)
                    }
                }
            }
        }
    }
    
    // MARK:- Get Screen Ratio
    // AVCaptureDevice 종류와 선택한 스크린 사이즈 비율에 맞게 PreviewImageView Frame 변경
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
    
    
    // MARK: Permission Check
    // -> SetUp the Camera
    func checkCameraPermission() {
        // 카메라 하드웨어 사용가능 여부 판단.
        let availableCameraHardware:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
        captureButton.isEnabled = availableCameraHardware
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)


        if let authorizationStatusOfCamera = authorizationStatus, availableCameraHardware {
            switch authorizationStatusOfCamera {
            case .authorized:
                print(authorizationStatusOfCamera)
                setUpCamera() // 카메라 setup
                
            case .denied:
                showNotice(alertCase: .camera) // 접근 권한이 없으므로 사용자에게 설정 - gaak - 카메라 허가 요청 UIAlertController 호출
                
                disableCameraOptionButton() // 플래쉬, 스위칭 버튼 disabled
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler : { (granted: Bool) in
                    
                    if granted {
                        
                        // GCD
                        DispatchQueue.main.async {
                            self.setUpCamera() // 카메라 setup
                        }
                        
                    } else {
                        print(granted)
                        
                        // GCD
                        DispatchQueue.main.async {
                            self.disableCameraOptionButton() // 플래쉬, 스위칭 버튼 disabled
                        }
                    }
                })
                
            case .restricted:
                print(authorizationStatusOfCamera)
                
            @unknown default:
                print("authorizationStatusOfCamera is unknown")
            }
        }
    }
    
    // 확인 후 수정필요(아래 버전)
    func showNotice(alertCase : SettingType){
        
        let alertController = UIAlertController(title: AlertContentConstant.titles[alertCase.rawValue], message: AlertContentConstant.messages[alertCase.rawValue], preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: AlertContentConstant.setting, style: .default, handler: { (action:UIAlertAction) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl!)
            }
            
        }))
        alertController.addAction(UIAlertAction(title: AlertContentConstant.cancel, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
        
    
    // MARK:- Setup and configure UI
    
    func disableCameraOptionButton(){
        // 카메라 옵션 버튼생성 후 활성화할 것.
        //switchOfCameraBarButtonItem.isEnabled = false
        //flashOfCameraBarButtonItem.isEnabled = false
    }
}
