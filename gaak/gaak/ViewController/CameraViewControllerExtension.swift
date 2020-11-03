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
import Haptica
import SnapKit
import Foundation

extension CameraViewController {
    
    
    //MARK: 사진 촬영
    
    // 촬영 버튼 Tap !
    @IBAction func tapCaptureButton(_ sender: Any) {
        if isOn_fiveTimesCapture == true {
            capturePhotoWithOptionsAndFiveTimes()
        } else if isOn_fiveTimesCapture == false {
            capturePhotoWithOptions()
        }
    }
    
    func capturePhotoWithOptions(){
        //off(default) == 0 || 3초 == 1 || 5초 == 2 || 10초 == 3
        //var timerID: Timer
        if (timerStatus != 0) {
            
            var countDown = setTime
            
            if(isCounting == true) { // 타이머 동작 중간에 취소하고싶다면,
                self.timeLeft.text = String(self.setTime) // * reset
                self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                self.countTimer.invalidate()
                
                self.isCounting = false
                self.captureButtonInner.image = UIImage(systemName: "circle.fill", withConfiguration: .none)
                self.captureButtonInner.tintColor = .systemRed
                // !!!주의!!! 이 곳의 x_o_temp 이미지를 원래대로 돌려야 함.
                return
            }

            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.countTimer = timer
                
                self.isCounting = true
                // 실행중에는 캡쳐버튼의 UI가 x로 변함.
                self.captureButtonInner.image = UIImage(named: "x_temp")
                
                self.timeLeft.text = String(countDown - 1)
                
                UIView.transition(with: self.timeLeft, duration: 0.3, options: .transitionCrossDissolve, animations: .none, completion: nil)
                
                if(countDown == 1){
                    self.capturePhoto()
                    self.timeLeft.isHidden = true // * 0일때는 사라짐
                }
                else if (countDown == 0) {
                    self.timeLeft.text = String(self.setTime) // * reset
                    self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                    self.countTimer.invalidate()
                    self.isCounting = false
                    // !!!주의!!! 이 곳의 x_o_temp 이미지를 원래대로 돌려야 함.
                    self.captureButtonInner.image = UIImage()
                    self.captureButtonInner.backgroundColor = .systemRed
                    // !!!주의!!!
                }
                countDown -= 1
            }
        } else {
            capturePhoto()
        }
    }
    
    func capturePhotoWithOptionsAndFiveTimes(){
        //off(default) == 0 || 3초 == 1 || 5초 == 2 || 10초 == 3
        //var timerID: Timer
        if (timerStatus != 0) {
            
            var countDown = setTime
            
            if(isCounting == true) { // 타이머 동작 중간에 취소하고싶다면,
                self.timeLeft.text = String(self.setTime) // * reset
                self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                self.countTimer.invalidate()
                
                self.isCounting = false
                self.captureButtonInner.image = UIImage(systemName: "circle.fill", withConfiguration: .none)
                self.captureButtonInner.tintColor = .systemRed
                // !!!주의!!! 이 곳의 x_o_temp 이미지를 원래대로 돌려야 함.
                return
            }

            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.countTimer = timer
                
                self.isCounting = true
                // 실행중에는 캡쳐버튼의 UI가 x로 변함.
                self.captureButtonInner.image = UIImage(named: "x_temp")
                
                self.timeLeft.text = String(countDown - 1)
                
                UIView.transition(with: self.timeLeft, duration: 0.3, options: .transitionCrossDissolve, animations: .none, completion: nil)
                
                if(countDown == 1){
                    self.capturerPhotoFiveTimes()
                    self.timeLeft.isHidden = true // * 0일때는 사라짐
                }
                else if (countDown == 0) {
                    self.timeLeft.text = String(self.setTime) // * reset
                    self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                    self.countTimer.invalidate()
                    self.isCounting = false
                    // !!!주의!!! 이 곳의 x_o_temp 이미지를 원래대로 돌려야 함.
                    self.captureButtonInner.image = UIImage()
                    self.captureButtonInner.backgroundColor = .systemRed
                    // !!!주의!!!
                }
                countDown -= 1
            }
        } else {
            capturerPhotoFiveTimes()
        }
    }
    
    
    func capturePhoto() {
        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation
        self.sessionQueue.async {
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!
            connection?.videoOrientation = .portrait
            // 캡쳐 세션에 요청하는것
            let setting = AVCapturePhotoSettings()
            setting.flashMode = self.getCurrentFlashMode(self.isOn_flash)
            self.photoOutput.capturePhoto(with: setting, delegate: self)
        }
    }
    
    //사진 연속 5장 촬영
    func capturerPhotoFiveTimes() {
        capturePhoto()
        capturePhoto()
        capturePhoto()
        capturePhoto()
        capturePhoto()
    }

//  [old] func capturePhoto() 으로 변경되었음.
//    @IBAction func capturePhoto(_ sender: Any) {
//        // TODO: photoOutput의 capturePhoto 메소드
//        // orientation
//        // photooutput
//        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation
//        sessionQueue.async {
//            let connection = self.photoOutput.connection(with: .video)
//            connection?.videoOrientation = videoPreviewLayerOrientation!
//            connection?.videoOrientation = .portrait
//            // 캡쳐 세션에 요청하는것
//            let setting = AVCapturePhotoSettings()
//            self.photoOutput.capturePhoto(with: setting, delegate: self)
//        }
//    }
    
    // MARK: - 저장1. 화면비에 맞게 자르기
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
                        
            let photoRatio = CGRect(x: 0, y: (image.size.height - image.size.width)/2.0, width: image.size.width, height: image.size.width)
            croppedImage = cropImage2(image: image, rect: photoRatio, scale: 1.0) ?? image
        }
        else if( screenRatioSwitchedStatus == 1 ) {
            
            let rectRatio = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width*4.0/3.0)
                        
            croppedImage = cropImage2(image: image, rect: rectRatio, scale: 1.0) ?? image
        }
        else if( screenRatioSwitchedStatus == 2 ) {
            
            let rectRatio = CGRect(x: (image.size.width)/(4.0)/(2.0), y: 0, width: (image.size.height)*(9.0)/(16.0), height: image.size.height)
            
            croppedImage = cropImage2(image: image, rect: rectRatio, scale: 1.0) ?? image
        }
        
        self.savePhotoLibrary(image: resizeImage(image: croppedImage, newWidth: 1080))
    }
    
    //MARK: 저장2. 라이브러리에 저장
    func savePhotoLibrary(image: UIImage) {
        // TODO: capture한 이미지 포토라이브러리에 저장
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // save !
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (_, error) in
                    self.setLatestPhoto() // 앨범버튼 썸네일 업데이트
                }
            } else {
                print(" error to save photo library")
                // 다시 요청할 수도 있음
                // ...
            }
        }
    }
    
    func cropImage2 (image : UIImage, rect : CGRect, scale : CGFloat)-> UIImage? {
        UIGraphicsBeginImageContextWithOptions (
            CGSize (width : rect.size.width / scale, height : rect.size.height / scale), true, 0.0)
        image.draw (at : CGPoint (x : -rect.origin.x / scale, y : -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    
    
    // Technique #2. UIKit에서 이미지 리사이징
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()
        return newImage
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
    
    
    //MARK: 더보기 상태 + 버튼 UI 컨트롤
    // gesture recognizer, 더보기창을 켜고 끔
    @IBAction func seeMore(_ sender: Any) {
        if(moreView.isHidden == true) {
            moreView.isHidden = false
            moreView.alpha = 1
        } else if (moreView.isHidden == false) {
            moreView.isHidden = true
        }
    }
    // gesture recognizer, 더보기창이 켜져있다면 끔
    @IBAction func returnToMain(_ sender: Any) {
        // return to main View
        if (!moreView.isHidden) {
            moreView.isHidden = true
        }
    }
    
    // MARK: 플래시 상태 + 버튼 UI 컨트롤
    // gesture recognizer, 플래시를 켜고 끔
    @IBAction func touchedFlashBtn(_ sender: Any) {
        if(isOn_flash == false){
            isOn_flash = true
            flashButton.setImage(UIImage(named: "flashOn"), for: .normal)
        }
        else if (isOn_flash == true){
            isOn_flash = false
            flashButton.setImage(UIImage(named: "flashOff"), for: .normal)
        }
    }
    
    // 현재 플래시 상태를 캡쳐세션에 전달하기 위한 함수
    func getCurrentFlashMode(_ mode : Bool) -> AVCaptureDevice.FlashMode{
        
        var valueOfAVCaptureFlashMode: AVCaptureDevice.FlashMode = .off
        
        switch mode {
        case false:
            valueOfAVCaptureFlashMode = .off
        case true:
            valueOfAVCaptureFlashMode = .on
        }
        return valueOfAVCaptureFlashMode
    }
    
    // MARK: 터치촬영 상태 + 버튼 UI 컨트롤
    // gesture recognizer, 플래시를 켜고 끔
    @IBAction func touchedTouchCapterBtn(_ sender: Any) {
                if (isOn_touchCapture == false) {
            isOn_touchCapture = true
            touchCaptureButton.setImage(#imageLiteral(resourceName: "touchCaptureOn"), for: .normal)
        } else if (isOn_touchCapture == true){
            isOn_touchCapture = false
            touchCaptureButton.setImage(#imageLiteral(resourceName: "touchCaptureOff"), for: .normal)
        }
    }
    
    // touchCaptureTrigger: 터치촬영 동작!
    @IBAction func touchCapture(_ sender: Any) {
        
        // return to main View
        // 더보기창이 켜져있다면 더보기창을 닫고 return
        if (moreView.isHidden == false) {
            moreView.isHidden = true
            return
        }
        /// 물리적으로 touch 를 1번만 할 수는 없기에, 2번째에는 이게 활성화됨
        /// 즉 장ㅊㅣ를 하나 더 만들어야함.
        if isOn_touchCapture {
            // isOn_touchCapture == true
            capturePhotoWithOptions()
        }
    }
    
    // MARK: 타이머 상태 + 버튼 UI + 중앙UILabel
    // gesture recognizer, 타이머 0초(기본값), 3초, 5초, 10초
    @IBAction func timerButton(_ sender: Any) {
        
        timerStatus += 1
        timerStatus %= 4
        
        switch timerStatus {
        case 0:
            setTime = 0
            timerButton.setImage(UIImage(named: "timer0"), for: .normal)
            timeLeft.isHidden = true
        case 1:
            setTime = 3
            timerButton.setImage(UIImage(named: "timer3"), for: .normal)
            timeLeft.isHidden = false
            timeLeft.text = String(setTime)
        case 2:
            setTime = 5
            timerButton.setImage(UIImage(named: "timer5"), for: .normal)
            timeLeft.isHidden = false
            timeLeft.text = String(setTime)
        case 3:
            setTime = 10
            timerButton.setImage(UIImage(named: "timer10"), for: .normal)
            timeLeft.isHidden = false
            timeLeft.text = String(setTime)
            
        default:
            break
        }
    }
    
    // MARK: 그리드 상태 + 버튼 UI 컨트롤
    // gesture recognizer
    @IBAction func gridButton(_ sender: Any) {
        isOn_Grid = !isOn_Grid
        if isOn_Grid {
            gridviewView.isHidden = false
            gridButton.setImage(#imageLiteral(resourceName: "onGrid"), for: .normal)
        } else {
            gridviewView.isHidden = true
            gridButton.setImage(#imageLiteral(resourceName: "offGrid"), for: .normal)
        }
    }
    
    //MARK: 화면비 상태 + 변경 UI 컨트롤
    // gesture recognizer
    /*     이 함수에서 화면비 아이콘도 변경하고 previewView의 사이즈도 변경함. */
    @IBAction func switchScreenRatio(_ sender: Any) {
        // 0 == 1:1 || 1 == 3:4 || 2 == 9:16
        
        screenRatioSwitchedStatus += 1
        screenRatioSwitchedStatus %= ScreenType.numberOfRatioType()
        if let currentPosition = self.currentPosition {
            switch screenRatioSwitchedStatus {
            case ScreenType.Ratio.square.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_1")

            case ScreenType.Ratio.retangle.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_3_4")
            
            case ScreenType.Ratio.full.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_9_16")

            default:
                break;
            }
            
            setToolbarsUI()
            
            // getSizeBy... // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위한 함수임.
            // 이거 필요없으면 나중에 삭제하는게 좋음 // extension으로 빼놨음.
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)
        }
    }
    
    //MARK: 상하단 툴바 설정 + Draw Grid
    // + Draw Grid Simple.ver
    func setToolbarsUI(){
        
        // get safeAreaHeight !!!
        let verticalSafeAreaInset = self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top
        let safeAreaHeight = self.view.frame.height - verticalSafeAreaInset
        
        settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        //cameraToolsView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        
        // 화면비에 따른 상, 하단 툴바 상태 조절
        switch screenRatioSwitchedStatus {
        case ScreenType.Ratio.square.rawValue :
            // 1:1 // tool bar UI 설정하는 부분
            
            settingToolbar.isTranslucent = false
            cameraToolsView.backgroundColor = CustomColor.uiColor("black")
            
            previewViewHeight.constant = view.frame.width * (4.0/3.0)
            gridViewHeight.constant = view.frame.width
            settingToolbarHeight.constant = (previewViewHeight.constant - view.frame.width)/2.0
            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - (view.frame.width + settingToolbar.frame.size.height))
            }
            
            // draw grid (simple.ver)
            gridH1.constant = gridviewView.frame.width / 3
            gridH2.constant = -(gridviewView.frame.width / 3)
            gridV1.constant = gridviewView.frame.width / 3
            gridV2.constant = -(gridviewView.frame.width / 3)
        
        case ScreenType.Ratio.retangle.rawValue :
            // 3:4
            settingToolbar.isTranslucent = true
            cameraToolsView.backgroundColor = CustomColor.uiColor("clear")
            
            gridViewHeight.constant = previewViewHeight.constant

            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - ((view.frame.size.width)*(4.0/3.0)))
            }
            
            // draw grid (simple.ver)
            gridH1.constant = (previewView.frame.width * (4.0/3.0)) / 3
            gridH2.constant = -(previewView.frame.width * (4.0/3.0)) / 3
            gridV1.constant = previewView.frame.width / 3
            gridV2.constant = -(previewView.frame.width / 3)

        case ScreenType.Ratio.full.rawValue :
            // 9:16
            settingToolbar.isTranslucent = true
            cameraToolsView.backgroundColor = CustomColor.uiColor("clear")
            
            previewViewHeight.constant = view.frame.size.width * (16.0/9.0)
            gridViewHeight.constant = previewViewHeight.constant
            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - ((view.frame.size.width)*(4.0/3.0)))
            }
            
            // draw grid (simple.ver)
            gridH1.constant = (previewView.frame.width * (16.0/9.0)) / 3
            gridH2.constant = -(previewView.frame.width * (16.0/9.0)) / 3
            gridV1.constant = previewView.frame.width / 3
            gridV2.constant = -(previewView.frame.width / 3)

        default:
            print("--> screenRatioSwitchedStatus: default")
        }
    }
    
    // MARK: 5장 연속 촬영 상태 + UI 컨트롤
    @IBAction func fiveTimesCapturPhoto(_ sender: Any) {
        if(isOn_fiveTimesCapture == false){
            isOn_fiveTimesCapture = true
            fiveTiemsCapturButton.setImage(UIImage(named: "live" ), for: .normal)
        }
        else if (isOn_fiveTimesCapture == true){
            isOn_fiveTimesCapture = false
            fiveTiemsCapturButton.setImage(UIImage(named: "live_off" ), for: .normal)
        }
    }
    
    // MARK: 앨범버튼 썸네일 설정
    func setLatestPhoto(){
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                self.imageManger = PHCachingImageManager()
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                
                let asset: PHAsset = self.assetsFetchResults![0]
                self.imageManger?.requestImage(for: asset,
                                               targetSize: CGSize(width: 50, height: 50),
                                               contentMode: PHImageContentMode.aspectFill,
                                               options: nil,
                                               resultHandler: { (result : UIImage?, info) in
                                                DispatchQueue.main.async {
                                                    self.photosButton.setImage(result, for: .normal)
                                                    self.photosButton.layer.cornerRadius = 10
                                                    self.photosButton.layer.masksToBounds = true
                                                    self.photosButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                                                    self.photosButton.layer.borderWidth = 1
                                                    self.photosButton.snp.makeConstraints {
                                                        $0.width.height.equalTo(50)
                                                    }
                                                } } )
                
                //self.photoAlbumCollectionView?.reloadData()

           
            case .denied:
                print(authorizationStatusOfPhoto)
            case .notDetermined:
                print(authorizationStatusOfPhoto)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print(authorizationStatusOfPhoto)
            case .limited:
                print("접근제한(.limited): \(authorizationStatusOfPhoto)")
            @unknown default:
                print("@unknown error: \(authorizationStatusOfPhoto)")
            }
        }
    }
    
    
    // MARK: 수평, 수직계 Indicator
    func setGravityAccelerator() {
        var isImpactH: Bool = true
        var isImpactV: Bool = true
        
        /// 조금 더 찰지게 해보려고 삼각함수 적용해보았으나 실효성을 느끼지 못했음.
        /// 팀원들에게 테스트해보고 결정할 것. ex) let sin_x = sin( x * (.pi/2) )

        motionKit.getGravityAccelerationFromDeviceMotion(interval: 0.02) { (x, y, z) in
            // x(H)가 좌-1 우+1, z(V)가 앞-1 뒤+1
            let roundedX = Float(round(x * 100)) / 100.0
            let roundedZ = Float(round(z * 100)) / 100.0
            
            var current: Float
            var transform: CATransform3D
            
            current = roundedX * 90
            
            if (current < 2 && current > -2) { // 임계값 도달
                self.horizonIndicatorInner.tintColor = .systemGreen
                self.horizonIndicatorOuter.tintColor = .systemGreen
                current = 0
                
                if isImpactH {
                    Haptic.play("ooo--OOOOO-", delay: 0.1)
                    isImpactH = false
                }
            }
            else { // 임계값 이탈
                self.horizonIndicatorInner.tintColor = .systemRed
                self.horizonIndicatorOuter.tintColor = .systemRed
                if (!isImpactH) {
                    Haptic.play("-", delay: 0.1)
                    isImpactH = true
                }
            }
            
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(current * Float.pi / 180), 0, 0, 1
            )
            self.horizonIndicator.transform3D = transform
            
            current = roundedZ * 90
            if (current < 3 && current > -3) { // 임계값 도달
                self.captureButtonInner.alpha = 1.0
                self.captureButtonInner.tintColor = .systemGreen
                self.captureButtonOuter.tintColor = .systemGreen
                
                if isImpactV {
                    Haptic.play("o-Oo", delay: 0.1)
                    isImpactV = false
                }
            }
            else { // 임계값 이탈
                self.captureButtonInner.alpha = CGFloat(-abs(current/100))+1.0
                self.captureButtonInner.tintColor = .systemRed
                self.captureButtonOuter.tintColor = .systemRed
                
                if !isImpactV {
                    Haptic.play("-", delay: 0.1)
                    isImpactV = true
                }
            }
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(current * Float.pi / 180), 1, 0, 0
            )
            self.captureButtonInner.transform3D = transform
        }
    }
    
    // MARK:- FocusMode, draw and move focus Box.
    // 초점맞추는 기능
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
        // 또는 터치촬영모드일 경우 초점을 재조정할 수 없습니다.
        if isOn_touchCapture {
            return
        }
        
        // 더보기 창이 켜져있다면 초점을 재조정할 수 없습니다.
        // 더보기창을 닫습니다.
        if (!moreView.isHidden) {
            moreView.isHidden = true
            return
        }
        
        if let coordinates = touches.first, let device = captureDevice {
            
            // 터치 가능 영역을 벗어났을 경우입니다.
            if (coordinates.location(in: self.view).y < gridviewView.frame.minY || coordinates.location(in: self.view).y > gridviewView.frame.maxY){
                return // 현재 터치된 곳은 초점을 맞출 수 없는 곳입니다.
            }
            
            // 전면 카메라는 FocusPointOfInterest를 지원하지 않습니다.
            if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                let focusPoint = touchPercent(touch : coordinates)
                dump(focusPoint)

                do {
                    try device.lockForConfiguration()

                    // FocusPointOfInterest 를 통해 초점을 잡아줌.
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()

                    if focusBox != nil {
                        // 초점 박스가 있으면 위치를 바꿔줌
                        changeFocusBoxCenter(for: coordinates.location(in: previewView))
                    } else {
                        // 초점 박스가 없으면 그려줌
                        makeRectangle(at : coordinates)
                    }

                    previewView.addSubview(self.focusBox)
                    
                    zoomFocusOutIn(view: self.focusBox, delay: 1)
                    // fadeViewInThenOut(view: self.focusBox, delay: 1)
                    
                } catch{
                    fatalError()
                }
            }
            // 전면 카메라에서는 FocusPointOfInterest 를 지원하지 않는다.

        }
    }
    
    // 초점 박스를 이동하는 메소드
    func changeFocusBoxCenter(for location: CGPoint )
    {
        self.focusBox.center.x = location.x
        self.focusBox.center.y = location.y
    }
    
    func touchPercent(touch coordinates: UITouch) -> CGPoint {
        
        // 0~1.0 으로 x, y 화면대비 비율 구하기
        let x = coordinates.location(in: previewView).y / previewView.bounds.height
        let y = 1.0 - coordinates.location(in: previewView).x / previewView.bounds.width
        let ratioOfPoint = CGPoint(x: x, y: y)
        
        return ratioOfPoint
    }
    
    func makeRectangle(at coordinates : UITouch) {
        
        // 화면 사이즈 구하기
        let screenBounds = previewView.bounds
        
        // 화면 비율에 맞게 정사각형의 focus box 그리기
        var rectangleBounds = screenBounds
        rectangleBounds.size.width = screenBounds.size.width / 6
        rectangleBounds.size.height = screenBounds.size.width / 6
        
        // 터치된 좌표에 focusBox의 높이, 너비의 절반 값을 빼주어서 터치한 좌표를 중심으로 그려지게 설정
        rectangleBounds.origin.x = coordinates.location(in: previewView).x - (rectangleBounds.size.width / 2)
        rectangleBounds.origin.y = coordinates.location(in: previewView).y - (rectangleBounds.size.height / 2)
        
        self.focusBox = UIView(frame: rectangleBounds)
        self.focusBox.layer.borderColor = UIColor.init(red: 1.0, green: 1.0, blue: 0, alpha: 1).cgColor
        self.focusBox.layer.borderWidth = 1
        self.focusBox.alpha = 0.25

    }
    
    // MARK: - Animation Focus Rect
    func zoomFocusOutIn(view: UIView, delay: TimeInterval) {
        let animationDuration = 0.25
        
        let viewFrame = view.frame
        
        view.frame.centerX = viewFrame.centerX - viewFrame.width / 4
        view.frame.centerY = viewFrame.centerY - viewFrame.height / 4
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.frame.centerX = viewFrame.centerX + 0
            view.frame.centerY = viewFrame.centerY + 0
            view.frame.size = CGSize(width: view.frame.width / 2, height: view.frame.width / 2)
            view.alpha = 1
        }) { (Bool) -> Void in
            // After the animation completes, fade out the view after a delay
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0.25
                },
            completion: nil
            )
        }

        view.frame.size =  CGSize(width: view.frame.width * 2, height: view.frame.width * 2)
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.1
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0.25
                },
            completion: nil
            )
        }
    }
}
