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
import Loaf

extension CameraViewController {
    
    
    //MARK: 사진 촬영
    
    // 촬영 버튼 Tap !
    @IBAction func tapCaptureButton(_ sender: Any) {
        Haptic.play("o", delay: 0.1)

        capturePhotoWithOptions()
    }
    
    func capturePhotoWithOptions(){
        //off(default) == 0 || 3초 == 1 || 5초 == 2 || 10초 == 3
        //var timerID: Timer
        
        if (timerStatus != 0) {
            
            var countDown = setTime
            
            if(isCounting == true) { // 타이머 동작 중간에 취소할때 동작함.
                guard self.countTimer != nil else { return }
                
                DispatchQueue.main.async {
                    self.timeLeft.text = String(self.setTime) // * reset
                    self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                }
                
                self.countTimer?.invalidate()
                
                self.isCounting = false
                // self.captureButtonInner.image = #imageLiteral(resourceName: "shutter_inner_true")
                // self.captureButtonInner.tintColor = .systemRed
                // !!!주의!!! 이 곳의 x_o_temp 이미지를 원래대로 돌려야 함.
                    
                // 각도기능 재개
                setGravityAccelerator()
                
                return
            }
            
            self.isCounting = true
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
                
                self.countTimer = timer
                
                self.isCounting = true
                
                // 실행중에는 캡쳐버튼의 UI가 x로 변함.
                DispatchQueue.main.async {
                    self.captureButtonInner.image = #imageLiteral(resourceName: "xCircle")
                    self.captureButtonInner.alpha = 1.0
                }
                
                // 각도기능 멈춤
                motionKit.stopDeviceMotionUpdates()
                self.captureButtonInner.transform = CGAffineTransform.identity
                
                DispatchQueue.main.async {
                    self.timeLeft.text = String(countDown)
                    
                    UIView.transition(with: self.timeLeft, duration: 0.3, options: .transitionCrossDissolve, animations: .none, completion: nil)
                }
                if(countDown == 1){
                    if self.isOn_continuousCapture {
                        for _ in 1...5{
                            self.capturePhoto()
                        }
                    }
                    else { self.capturePhoto() }
                    self.timeLeft.isHidden = true // * 0일때는 사라짐
                }
                else if (countDown == 0) {
                    DispatchQueue.main.async {
                        self.timeLeft.text = String(self.setTime) // * reset
                        self.timeLeft.isHidden = false // * reSet 하고 다시 보여줌
                        self.captureButtonInner.image = #imageLiteral(resourceName: "shutter_inner_true")
                    }
                    self.countTimer?.invalidate()
                    self.isCounting = false

                    
                    // 각도 기능 재개
                    setGravityAccelerator()

                }
                countDown -= 1
            }
        } else {
            if self.isOn_continuousCapture {
                for _ in 1...5{
                    self.capturePhoto()
                }
            }
            else { self.capturePhoto() }
        }
    }
    
    func capturePhoto() {
        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation
        
        
        /// test
        self.sessionQueue.async {
        //DispatchQueue.main.async {
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!

            //connection?.videoOrientation =
            //connection?.videoOrientation = .portrait
            
            // 캡쳐 세션에 요청하는것
            let setting = AVCapturePhotoSettings()
            setting.flashMode = self.getCurrentFlashMode(self.isOn_flash)
            
            self.photoOutput.capturePhoto(with: setting, delegate: self)

        }
    }
    
    // MARK: - 저장1. 화면비에 맞게 자르기
    // 사진 저장할 때 화면비에 맞게 잘라서 저장해주는 함수
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }

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
        
        // 가로모드 분류! .portrait .landscapeLeft .landscapeRight
        let rotatedImage: UIImage!
        switch deviceOrientation {
        case 3: // .landscapeLenft
            rotatedImage = croppedImage.imageRotatedByDegrees(degrees: +90)
        case 4: // .landscapeLenft
            rotatedImage = croppedImage.imageRotatedByDegrees(degrees: -90)
        default:
            rotatedImage = croppedImage
        }
        
        self.savePhotoLibrary(image: resizeImage(image: rotatedImage, newWidth: 1080))
        
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
        /// 즉 장치를 하나 더 만들어야함.
        if isOn_touchCapture {
            // isOn_touchCapture == true
            capturePhotoWithOptions()
        }
    }
    
    // MARK: 그리드 상태 + 버튼 UI 컨트롤
    // gesture recognizer
    @IBAction func gridButton(_ sender: Any) {
        
        if isOn_Grid {
            gridviewView.isHidden = true
            gridButton.setImage(#imageLiteral(resourceName: "Grid_off"), for: .normal)
        } else if !isOn_Grid {
            gridviewView.isHidden = false
            gridButton.setImage(#imageLiteral(resourceName: "Grid_on"), for: .normal)
        }
        
        isOn_Grid = !isOn_Grid
    }
    
    // MARK: 연속촬영 상태 + 버튼 UI 컨트롤
    // gesture recognizer // To do: 이미지 변경 필요
    @IBAction func continuousCaptureButton(_ sender: Any) {
        
        if(isOn_continuousCapture == false){
            isOn_continuousCapture = true
            continuousCaptureButton.setImage(#imageLiteral(resourceName: "continuous shooting_on"), for: .normal)
        }
        else if (isOn_continuousCapture == true){
            isOn_continuousCapture = false
            continuousCaptureButton.setImage(#imageLiteral(resourceName: "continuous shooting_off"), for: .normal)
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
                screenRatioBarButtonItem.image = UIImage(named: "Ratio_11")

            case ScreenType.Ratio.retangle.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "Ratio_34")
            
            case ScreenType.Ratio.full.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "Ratio_916")

            default:
                break;
            }
            
            setToolbarsUI()
            
            setLayoutMode()

            
            // getSizeBy... // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위한 함수임.
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)
        }
    }
    
    //MARK: 상하단 툴바 설정 + Draw Grid
    func setToolbarsUI(){
        
        // 화면비 기준 측정 -> 기준은 0.5으로 함.
        // ~iPhone 8+ = 0.5625 // 9:16 -> oldPhone
        // iPhons X ~ < 0.462
        
        // 1:1 화면비를 위해 previewView상단을 가려야 함.
                
        if oldPhone { //MARK: oldPhone
            
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
                
                settingToolbar.isTranslucent = true
                settingToolbar.backgroundColor = .black
                settingToolbar.barTintColor = .black

                cameraToolsView.backgroundColor = CustomColor.uiColor("black")
                
                previewViewHeight.constant = view.frame.width * (4.0/3.0)
                gridViewHeight.constant = view.frame.width
                settingToolbarHeight.constant = (previewViewHeight.constant - view.frame.width)/2.0
                
                cameraToolsView.snp.updateConstraints {
                    $0.height.equalTo(safeAreaHeight - (view.frame.width + settingToolbarHeight.constant))
                }
                
                // draw grid (simple.ver)
                gridH1.constant = gridviewView.frame.width / 3
                gridH2.constant = -(gridviewView.frame.width / 3)
                gridV1.constant = gridviewView.frame.width / 3
                gridV2.constant = -(gridviewView.frame.width / 3)
            
            case ScreenType.Ratio.retangle.rawValue :
                // 3:4
                settingToolbar.isTranslucent = true
                settingToolbar.backgroundColor = .clear
                settingToolbar.barTintColor = .red
                settingToolbar.tintColor = .clear
                blindView.backgroundColor = .clear
                
                cameraToolsView.backgroundColor = CustomColor.uiColor("clear")
                cameraToolsView.tintColor = .white
                gridViewHeight.constant = previewViewHeight.constant
                settingToolbarHeight.constant = (view.frame.width * (4.0/3.0) - view.frame.width)/2.0

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
                settingToolbar.backgroundColor = .clear
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
            
        } // </oldPhone>
        
        else {
            // MARK: iPhone X ~
            // get safeAreaHeight !!!
            let verticalSafeAreaInset = self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top
            let safeAreaHeight = self.view.frame.height - verticalSafeAreaInset
            
            settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            
            settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            settingToolbar.isTranslucent = true
            settingToolbarHeight.constant = 50

            cameraToolsView.backgroundColor = .clear
            
            previewView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(self.view.safeAreaInsets.top + settingToolbarHeight.constant)
            }
            
            blindView.snp.updateConstraints {
                $0.height.equalTo(50)
            }

            
            // 화면비에 따른 상, 하단 툴바 상태 조절
            switch screenRatioSwitchedStatus {
            case ScreenType.Ratio.square.rawValue :
                // 1:1 // tool bar UI 설정하는 부분
                
                blindView.snp.updateConstraints {
                    $0.height.equalTo(self.view.frame.width/6)
                }
                UIView.animate(withDuration: 0.05) {
                    self.blindView.transform = CGAffineTransform(translationX: 0, y: self.settingToolbarHeight.constant)
                }
                
                previewViewHeight.constant = view.frame.width * (4.0/3.0)
                gridViewHeight.constant = previewView.frame.width

                cameraToolsView.backgroundColor = .black
                cameraToolsView.snp.updateConstraints {
                    $0.height.equalTo(safeAreaHeight - (settingToolbarHeight.constant + 7*view.frame.size.width/6) )
                }
                
                // draw grid (simple.ver)
                gridH1.constant = gridviewView.frame.width / 3
                gridH2.constant = -(gridviewView.frame.width / 3)
                gridV1.constant = gridviewView.frame.width / 3
                gridV2.constant = -(gridviewView.frame.width / 3)
            
            case ScreenType.Ratio.retangle.rawValue :
                // 3:4
                
                UIView.animate(withDuration: 0.05) {
                    self.blindView.transform = CGAffineTransform.identity
                }
                
                previewViewHeight.constant = view.frame.width * (4.0/3.0)
                gridViewHeight.constant = previewViewHeight.constant
                
                cameraToolsView.snp.updateConstraints {
                    $0.height.equalTo(safeAreaHeight - (settingToolbarHeight.constant + (view.frame.size.width)*(4.0/3.0)))
                }
                
                // draw grid (simple.ver)
                gridH1.constant = (previewView.frame.width * (4.0/3.0)) / 3
                gridH2.constant = -(previewView.frame.width * (4.0/3.0)) / 3
                gridV1.constant = previewView.frame.width / 3
                gridV2.constant = -(previewView.frame.width / 3)
                
            case ScreenType.Ratio.full.rawValue :
                // 9:16
                
                previewViewHeight.constant = view.frame.size.width * (16.0/9.0)
                gridViewHeight.constant = previewViewHeight.constant
                
                // draw grid (simple.ver)
                gridH1.constant = (previewView.frame.width * (16.0/9.0)) / 3
                gridH2.constant = -(previewView.frame.width * (16.0/9.0)) / 3
                gridV1.constant = previewView.frame.width / 3
                gridV2.constant = -(previewView.frame.width / 3)
                
            default:
                print("--> screenRatioSwitchedStatus: default")
            }
            
            
        } // </ iPhone X ~>
    }
    
    
    // MARK: 레이아웃 모드 세팅
    func setLayoutMode() {
        // 전체 뷰의 백그라운드 컬러 변경
        let ratio = screenRatioSwitchedStatus

        
        // 기존 subviews를 삭제하는곳. 화면비 변환 등 UI를 update할 때마다 그에 맞는 비율로 생성해야 하기 때문
        for layoutSubview in scrollView.subviews {
            layoutSubview.removeFromSuperview()
        }
        
        // Get the vertical and horizontal sizes of the view.
        var width: CGFloat = 0, height: CGFloat = 0
        switch screenRatioSwitchedStatus {
        case 0:
            width = self.gridviewView.frame.width
            height = self.gridviewView.frame.width

            
            
            if oldPhone {
                layoutView.snp.remakeConstraints { (make) in
                    make.top.equalTo(settingToolbarHeight.constant)
                    make.height.equalTo(height)
                }
            }
            else {
                layoutView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.view.safeAreaInsets.top + settingToolbarHeight.constant + self.view.frame.width/6)
                    make.height.equalTo(height)
                }
            }
            
        case 1:
            width = self.gridviewView.frame.width
            height = self.gridviewView.frame.width * (4.0/3.0)
            layoutView.snp.remakeConstraints { (make) in
                make.top.equalTo(blindView.snp.bottom)
                make.height.equalTo(height)
            }
        case 2:
            width = self.gridviewView.frame.width
            height = self.gridviewView.frame.width * (16.0/9.0)
            layoutView.snp.remakeConstraints { (make) in
                make.top.equalTo(blindView.snp.bottom)
                make.height.equalTo(height)
            }
        default:
            print("default error")
        }
        
        for i in 0 ..< pageSize {
            let layoutImage: UIImageView = UIImageView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
            
            layoutImage.image = UIImage(named: "GuideLine\(ratio)-\(i)")
            
            scrollView.addSubview(layoutImage)
            
        }
        // Add UIScrollView, UIPageControl on view
        self.layoutView.addSubview(self.scrollView)
        
        
        self.view.addSubview(pageControl)
        
        if !isLaunched { // 최초 레이아웃뷰 위치 정의
            pageControl.snp.makeConstraints { (make) in
                //make.left.right.equalTo(self.view)
                make.leading.trailing.equalTo(self.view).offset(-60 * self.pageControl.currentPage)

                
                if self.realOldPhone { make.bottom.equalTo(self.cameraToolsView).inset(147) }
                else { make.bottom.equalTo(self.cameraToolsView).inset(155) }
                make.height.equalTo(20)
            }
            isLaunched = true
        }
        pageControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        pageControl.addTarget(self, action: #selector(pageControlSelectionAction(_:)), for: .touchDown)
    }
    
    // MARK: PageControl
    // 페이지 컨트롤 인터랙션 with 레이아웃뷰
    @objc @IBAction func pageControlSelectionAction(_ sender: UIPageControl) {

        let seconds = 0.2
        //DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + seconds) {
            
            self.scrollView.setContentOffset(CGPoint(x: (sender.currentPage) * Int(self.scrollView.frame.maxX), y: 0), animated: true)
            
            //self.pageControl.snp.removeConstraints()
            self.pageControl.snp.remakeConstraints { (make) in
                
                //make.left.equalTo(self.view).offset(-60 * sender.currentPage)
                make.leading.trailing.equalTo(self.view).offset(-60 * self.pageControl.currentPage)
                
                if self.realOldPhone { make.bottom.equalTo(self.cameraToolsView).inset(147) }
                else { make.bottom.equalTo(self.cameraToolsView).inset(155) }
                make.height.equalTo(20)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                //self.pageControl.layoutIfNeeded()
            }
        }
    }
    
    //MARK: 카메라 전후 전환 icon
    func updateSwitchCameraIcon(position: AVCaptureDevice.Position) {
        // TODO: Update ICON
        switch position {
        case .front:
            switchButton.setImage(#imageLiteral(resourceName: "ic_camera_front"), for: .normal)
        case .back:
            switchButton.setImage(#imageLiteral(resourceName: "ic_camera_rear"), for: .normal)
        default:
            break
        }
    }
    
    //MARK: 카메라 전후 전환 func
    @IBAction func switchCamera(sender: Any) {
        // 카메라는 2개 이상이어야함
        guard videoDeviceDiscoverySession.devices.count > 1 else { return }
        
        // seq: 반대 카메라 찾아서 재설정
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
                        self.captureSession.addInput(self.videoDeviceInput)
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
            else if (coordinates.location(in: self.view).y > cameraToolsView.frame.minY) {
                return // 현재 터치된 곳은 초점을 맞출 수 없는 곳입니다.
            }
            
            // 전면 카메라는 FocusPointOfInterest를 지원하지 않습니다.
            if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                let focusPoint = touchPercent(touch : coordinates)
                // dump(focusPoint)

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

        }
    }
    
    // 초점 박스를 이동하는 메소드
    func changeFocusBoxCenter(for location: CGPoint )
    {
        self.focusBox.center.x = location.x
        self.focusBox.center.y = location.y
    }
    // 터치된 곳 좌표 0~1 매핑
    func touchPercent(touch coordinates: UITouch) -> CGPoint {
        
        // 0~1.0 으로 x, y 화면대비 비율 구하기
        let x = coordinates.location(in: previewView).y / previewView.bounds.height
        let y = 1.0 - coordinates.location(in: previewView).x / previewView.bounds.width
        let ratioOfPoint = CGPoint(x: x, y: y)
        
        return ratioOfPoint
    }
    // Focus rectangle 만듦
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
    // MARK: - Animation fade in and out
    // 현재 사용되지 않는 함수임
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

                if self.assetsFetchResults.count == 0 {
                    DispatchQueue.main.async {
                        self.photosButton.setImage(#imageLiteral(resourceName: "photos"), for: .normal)
                        self.photosButton.layer.cornerRadius = 10
                        self.photosButton.layer.masksToBounds = true
                        self.photosButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        self.photosButton.layer.borderWidth = 1
                    }
                    return
                }
                
                if self.assetsFetchResults.count == 0 {
                    DispatchQueue.main.async {
                        self.photosButton.setImage(#imageLiteral(resourceName: "photos"), for: .normal)
                        self.photosButton.layer.cornerRadius = 10
                        self.photosButton.layer.masksToBounds = true
                        self.photosButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        self.photosButton.layer.borderWidth = 1
                    }
                    return
                }
                
                let asset: PHAsset = self.assetsFetchResults![0]
                
                self.imageManger?.requestImage(for: asset,
                                               targetSize: CGSize(width: 48, height: 48),
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
                                                        $0.width.height.equalTo(48)
                                                    }
                                                } } )
                
           
            case .denied:
                print("authorization denied(authorizationStatusOfPhoto: \(authorizationStatusOfPhoto)")
            case .notDetermined:
                print("authorization notDetermined(authorizationStatusOfPhoto: \(authorizationStatusOfPhoto)")
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print("authorization restricted(authorizationStatusOfPhoto: \(authorizationStatusOfPhoto)")
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
        var isImpactY: Bool = true
        var isSkyShot: Bool = false
        
        // Device Orientation Notifier
        motionKit.startDeviceOrientationNotifier { (deviceOrientation) in
            self.deviceOrientation = deviceOrientation.rawValue
            let duration = 0.3
            
            DispatchQueue.main.async {
                if self.deviceOrientation == 1 {
                    // portrait
                    UIView.animate(withDuration: duration) {
                        self.captureButtonView.transform = CGAffineTransform.identity
                    }
                }
                else if (self.deviceOrientation == 3){
                    // landscapeRight
                    UIView.animate(withDuration: duration) {
                        self.captureButtonView.transform = CGAffineTransform(rotationAngle: -.pi/2)
                    }
                }
                else if self.deviceOrientation == 4 {
                    // landscapeLeft
                    UIView.animate(withDuration: duration) {
                        self.captureButtonView.transform = CGAffineTransform(rotationAngle: +.pi/2)
                    }
                }
                
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
            } //</DispatchQueue>
        }

        motionKit.getGravityAccelerationFromDeviceMotion(interval: 0.02) { [self] (x, y, z) in
            // x(H)가 좌-1 우+1, z(V)가 앞-1 뒤+1
            var transform: CATransform3D
            
            /* Horizontal part */
            
            let roundedX = Float(round(x * 100)) / 100.0
            self.currentAngleH = roundedX * 90
            
            let roundedZ = Float(round(z * 100)) / 100.0
            self.currentAngleV = roundedZ * 90
            
            let roundedY = Float(round(y * 100)) / 100.0
            self.currentAngleY = roundedY * 90
            
            
            
            // 가로모드인지 아닌지 분류 -> 적용까지
            if deviceOrientation == 3 {
                currentAngleH = +currentAngleY
            }
            else if deviceOrientation == 4 {
                currentAngleH = -currentAngleY
            }
            
            // if 임시각도on -> 영점 조절
            if self.isOn_AnglePin == true {
                self.currentAngleH -= self.tempAngleH
            }
            
            // 색상 결정
            if (self.currentAngleH < 2 && self.currentAngleH > -2) { // 임계값 도달
                self.horizonIndicatorInner.tintColor = #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                self.horizonIndicatorOuter.tintColor = #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                self.currentAngleH = 0
                
                horizonIndicatorInner.snp.updateConstraints {
                    $0.width.equalTo(15)
                }
                
                if (isImpactH && !isSkyShot){
                    if( !ud.bool(forKey: "haptic") ) {
                        //print("haptic is on")
                        
                        Haptic.play("oo--OOOO-", delay: 0.1) // made by 인재
                        // Haptic.play("OO--Oo", delay: 0.1) // made by 동현
                    }
                    
                    isImpactH = false
                }
            }
            else { // 임계값 이탈
                self.horizonIndicatorInner.tintColor = #colorLiteral(red: 0.9568, green: 0.305, blue: 0.305, alpha: 1)
                self.horizonIndicatorOuter.tintColor = #colorLiteral(red: 0.9568, green: 0.305, blue: 0.305, alpha: 1)
                
                horizonIndicatorInner.snp.updateConstraints {
                    $0.width.equalTo(12)
                }
                
                if (!isImpactH) {
                    Haptic.play("-", delay: 0.1)
                    isImpactH = true
                }
            }
            
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(self.currentAngleH * Float.pi / 180), 0, 0, 1
            )
            self.horizonIndicator.transform3D = transform
            
            /* Vertical part */
            
            // if 임시각도on -> 영점 조절
            if self.isOn_AnglePin == true {
                self.currentAngleV -= self.tempAngleV
            }
            
            var tempAdjustAngleV = self.currentAngleV

            
            if (self.currentAngleV < 3 && self.currentAngleV > -3) { // 임계값 도달
                self.captureButtonInner.alpha = 1.0
                self.captureButtonInner.image = #imageLiteral(resourceName: "shutter_inner_true")
                self.captureButtonOuter.alpha = 1
                self.captureButtonOuter.image = #imageLiteral(resourceName: "shutter_right_out circle")
                
                self.currentAngleV = 0
                
                if isImpactV {
                    if( !ud.bool(forKey: "haptic") ) {
                        //print("haptic is on")
                        
                        //Haptic.play("o-Oo", delay: 0.1) // made by 인재
                        Haptic.play("OO-Oo", delay: 0.1)  // made by 동현
                    }
                    
                    isImpactV = false
                }
            }
            else { // 임계값 이탈
                tempAdjustAngleV = self.currentAngleV > 0 ? self.currentAngleV+20 : self.currentAngleV-20
                
                self.captureButtonInner.alpha = CGFloat(-abs(self.currentAngleV/100))+1.0
                self.captureButtonInner.image = #imageLiteral(resourceName: "shutter_inner_false")
                self.captureButtonOuter.alpha = 1
                self.captureButtonOuter.image = #imageLiteral(resourceName: "Shutter_out circle")
                
                if !isImpactV {
                    Haptic.play("-", delay: 0.1)
                    isImpactV = true
                }
            }
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(tempAdjustAngleV * Float.pi / 180), 1, 0, 0
            )
            
            self.captureButtonInner.transform3D = transform
            
        
            //MARK: 항공샷
            // 항공샷은 고정핀 해제상태에서만 가능합니다.
            if self.isOn_AnglePin == false {
                self.currentAngleH = roundedX * 90

                // 1. 항공샷 모드 임계각도에 진입 // 하면 중앙UI 표시
                if (-20 < self.currentAngleH && self.currentAngleH < 20
                        && -15 < currentAngleY && currentAngleY < 15) {
                    
                    isSkyShot = true
                    
                    // 배경화면 색 변경
                    self.view.backgroundColor = #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                    settingToolbar.backgroundColor = (oldPhone == true && screenRatioSwitchedStatus != 0) ? .clear : #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                    settingToolbar.barTintColor = (oldPhone == true && screenRatioSwitchedStatus != 0) ? .clear : #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                    blindView.backgroundColor = #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                    cameraToolsView.backgroundColor = screenRatioSwitchedStatus == 2 ? .clear : #colorLiteral(red: 0.0, green: 0.886, blue: 0.576, alpha: 1.0)
                    self.layoutView.isHidden = true
                    self.pageControl.isHidden = true
                    self.photosButton.isHidden = true
                    self.captureButtonInner.image = UIImage()
                    self.captureButtonOuter.image = #imageLiteral(resourceName: "Shutter_top view")
                    self.anglePin.isHidden = true
                    self.anglePinStatus.isHidden = true
                    
                    
                    
                    // 1.1. 기존 셔터 기능+UI 비활성화
                    // 1.1.1. H indicator(inner, outer) 비활성화 -> .clear
                    self.horizonIndicatorInner.tintColor = .clear
                    self.horizonIndicatorOuter.tintColor = .clear
                    
                    // 1.1.2. V indicator(inner) 비활성화 -> Identity
                    self.captureButtonInner.transform3D = CATransform3DIdentity
                    
                    
                    
                    //  1.2. 항공샷 기능+UI 활성화
                    self.skyShotInner.snp.updateConstraints {
                        $0.centerX.equalToSuperview().offset(self.currentAngleH * 2)
                        $0.centerY.equalToSuperview().offset((-currentAngleY) * 2)
                    }
                    
                    // 임계값 수직수평 도달
                    if (-3 < self.currentAngleH && self.currentAngleH < 3 && -2 < currentAngleY && currentAngleY < 2) {
                        
                        self.captureButtonOuter.alpha = 1
                        
                        if isImpactY {
                            if( !ud.bool(forKey: "haptic") ) {
                                //print("haptic is on")
                                
                                Haptic.play("OO-Oo", delay: 0.1)
                            }
                            isImpactY = false
                            
                            // sktShotFocus()
                        }
                        
                        self.skyShotInner.snp.updateConstraints {
                            $0.center.equalToSuperview()
                        }
                        self.skyShotOuter.tintColor = #colorLiteral(red: 1.0, green: 0.725, blue: 0.16, alpha: 1.0)
                        self.skyShotInner.tintColor = #colorLiteral(red: 1.0, green: 0.725, blue: 0.16, alpha: 1.0)
                        
                    }
                    // 항공샷 수직수평 임계각도 이탈
                    else {
                        
                        self.captureButtonOuter.alpha = 0.5

                        
                        if !isImpactY {
                            isImpactY = true
                        }
                        self.skyShotOuter.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
                        self.skyShotInner.tintColor = #colorLiteral(red: 1.0, green: 0.725, blue: 0.16, alpha: 1.0)
                    }
                    
                    
                    
                }
                else { // 항공샷 임계 각도 이탈
                    isSkyShot = false
                    
                    // 배경화면 색 원상복구
                    self.view.backgroundColor = .black
                    settingToolbar.backgroundColor = screenRatioSwitchedStatus != 0 ? .clear : .black
                    settingToolbar.barTintColor = screenRatioSwitchedStatus != 0 ? .clear : .black
                    blindView.backgroundColor = .black
                    cameraToolsView.backgroundColor = screenRatioSwitchedStatus == 2 ? .clear : .black
                    self.layoutView.isHidden = false
                    self.pageControl.isHidden = false
                    self.photosButton.isHidden = false

                    self.anglePin.isHidden = false
                    self.anglePinStatus.isHidden = false
                    
                    self.skyShotOuter.tintColor = .clear
                    self.skyShotInner.tintColor = .clear
                }
            } // </skyshot>
            
        } // </motionkit>
    } // </setGravityAccelerator()>
    
    // MARK: 각도 고정핀 상태 + UI
    // gesture recognizer
    @IBAction func touchedAnglePin(_ sender: Any) {
        
        // status point + 버튼 UI 회전
        if isOn_AnglePin == true {
            anglePinStatus.tintColor = .clear
            
            UIView.animate(withDuration: 0.25) {
                self.anglePin.transform = CGAffineTransform(rotationAngle: 0)
            }
            
            
            
            // 상단 알림
            DispatchQueue.main.async {
                Loaf.dismiss(sender: self)
                Loaf(TopAlert.no_Pin.rawValue,
                     state: .custom(.init(backgroundColor: .black, textColor: .white,
                                          tintColor: .green,
                                          font: UIFont(name: "SFProText-Medium", size: 13)!,
                                          icon: #imageLiteral(resourceName: "Alarm_pin_off"), textAlignment: .natural,
                                          width: .screenPercentage(0.53))),
                     location: .top, sender: self).show(.short)
            }
            
        }
        else if isOn_AnglePin == false {
            anglePinStatus.tintColor = .white
            
            UIView.animate(withDuration: 0.25) {
                self.anglePin.transform = CGAffineTransform(rotationAngle: -.pi/4)
            }
            
            // 현재 각도를 임시 기준각도로 저장
            if (deviceOrientation == 3) {
                tempAngleH = currentAngleY
            }
            else if (deviceOrientation == 4){
                tempAngleH = -currentAngleY
            }
            else { tempAngleH = currentAngleH }
            tempAngleV = currentAngleV
            
            // 상단 알림
            DispatchQueue.main.async {
                Loaf.dismiss(sender: self)
                Loaf(TopAlert.On_Pin.rawValue,
                     state: .custom(.init(backgroundColor: .black, textColor: .white,
                                          tintColor: .green,
                                          font: UIFont(name: "SFProText-Medium", size: 13)!,
                                          icon: #imageLiteral(resourceName: "Alarm_pin_on"), textAlignment: .natural,
                                          width: .screenPercentage(0.53))),
                     location: .top, sender: self).show(.short)
            }
        }
        isOn_AnglePin = !isOn_AnglePin
    }
}
