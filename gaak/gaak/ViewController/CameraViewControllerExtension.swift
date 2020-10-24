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
    
    //MARK: 사진 촬영
    @IBAction func capturePhoto(_ sender: UIButton) {
        // TODO: photoOutput의 capturePhoto 메소드
        // orientation
        // photooutput
        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation
        sessionQueue.async {
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!
            connection?.videoOrientation = .portrait
            // 캡쳐 세션에 요청하는것
            let setting = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: setting, delegate: self)
        }
    }
    
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
        
        //croppedImage를 리사이즈해야함.
        
        // cripImage2 함수도 같이 정리할 것.
        //guard let resizedImage = resizedImage(at: croppedImage, for: CGSize(width: 1080, height: 1080)) else { return }
        //self.savePhotoLibrary(image: resizedImage)
        
        
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
    
    
    // Technique #1. UIGraphicsImageRenderer
//    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
//
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { (context) in
//            image.draw(in: CGRect(origin: .zero, size: size))
//        }
//    }
    
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
    
    
    //MARK: 더보기 func
    // gesture control
    @IBAction func seeMore(_ sender: Any) {
        if(moreView.isHidden) {
            moreView.isHidden = false
            moreView.alpha = 1
        } else {
            moreView.isHidden = true
        }
        
        
    }
    // gesture control
    @IBAction func returnToMain(_ sender: Any) {
        // return to main View
        if (!moreView.isHidden) {
            moreView.isHidden = true
        }
    }
    
    //MARK: 화면비 변경 버튼
    /*     이 함수에서 화면비 아이콘도 변경하고 previewView의 사이즈도 변경함.
     */
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
        cameraToolsView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        cameraToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
//        cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        
        // 화면비에 따른 상, 하단 툴바 상태 조절
        switch screenRatioSwitchedStatus {
        case ScreenType.Ratio.square.rawValue :
            // setToolbarsUI // tool bar UI 설정하는 부분
            
//            cameraToolbar.isTranslucent = false
            cameraToolsView.backgroundColor = CustomColor.uiColor("black")
            settingToolbar.isTranslucent = false
            
            previewViewHeight.constant = view.frame.width * (4.0/3.0)
            gridViewHeight.constant = view.frame.width
            settingToolbarHeight.constant = (previewViewHeight.constant - view.frame.width)/2.0
            //cameraToolsView.translatesAutoresizingMaskIntoConstraints = false
            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - (view.frame.width + settingToolbar.frame.size.height))
            }
//            cameraToolBarHeight.constant = safeAreaHeight - (view.frame.width + settingToolbar.frame.size.height)
            
            /// draw grid (simple.ver)
            gridH1.constant = gridviewView.frame.width / 3
            gridH2.constant = -(gridviewView.frame.width / 3)
            gridV1.constant = gridviewView.frame.width / 3
            gridV2.constant = -(gridviewView.frame.width / 3)
            ///
        
        case ScreenType.Ratio.retangle.rawValue :
            //print("-> UI setup: screen_ratio 3_4")
            settingToolbar.isTranslucent = true
//            cameraToolbar.isTranslucent = false
            cameraToolsView.backgroundColor = CustomColor.uiColor("clear")
            
            gridViewHeight.constant = previewViewHeight.constant
//            cameraToolBarHeight.constant = safeAreaHeight - ((view.frame.size.width)*(4.0/3.0))
            print("hi hello")

            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - ((view.frame.size.width)*(4.0/3.0)))
            }
            
            /// draw grid (simple.ver)
            gridH1.constant = (previewView.frame.width * (4.0/3.0)) / 3
            gridH2.constant = -(previewView.frame.width * (4.0/3.0)) / 3
            gridV1.constant = previewView.frame.width / 3
            gridV2.constant = -(previewView.frame.width / 3)
            ///


        case ScreenType.Ratio.full.rawValue :
            //print("-> UI setup: screen_ratio 9:16")
            settingToolbar.isTranslucent = true
//            cameraToolbar.isTranslucent = true
            cameraToolsView.backgroundColor = CustomColor.uiColor("clear")
            
            previewViewHeight.constant = view.frame.size.width * (16.0/9.0)
            gridViewHeight.constant = previewViewHeight.constant
//            cameraToolBarHeight.constant = safeAreaHeight - ((view.frame.size.width)*(4.0/3.0))
            cameraToolsView.snp.updateConstraints {
                $0.height.equalTo(safeAreaHeight - ((view.frame.size.width)*(4.0/3.0)))
            }
            
            /// draw grid (simple.ver)
            gridH1.constant = (previewView.frame.width * (16.0/9.0)) / 3
            gridH2.constant = -(previewView.frame.width * (16.0/9.0)) / 3
            gridV1.constant = previewView.frame.width / 3
            gridV2.constant = -(previewView.frame.width / 3)
            ///

        default:
            print("--> screenRatioSwitchedStatus: default")
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
}
