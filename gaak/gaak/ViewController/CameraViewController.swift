//
//  CameraViewController.swift
//  gaak
//
//  Created by Ted Kim on 2020/09/14.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    // TODO: 초기 설정 1: 카메라 만드는데 필요한 객체들
    // - captureSession
    // - AVCaptureDeviceInput
    // - AVCapturePhotoOutput // Video도 따로 할 수 있음
    // - Queue // 디스패치 큐, 각 기능들이 수행될 때 다른 기능의 수행동작을 막지 않기 위해 사용
    // - AVCaptureDevice DiscoverySession // 폰에서 카메라를 가져올때 도와주는 요소
    
    let captureSession = AVCaptureSession() // 캡쳐세션을 만들었고
    var videoDeviceInput: AVCaptureDeviceInput! // 디바이스 인풋(을 담을 변수 생성, but 아직 카메라가 연결되지는 않음.)
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
        mediaType: .video,
        position: .unspecified
    )
    
    var screenRatioSwitchedStatus: Int = 0 // 화면 비율 구분을 위한 저장 프로퍼티
    var currentPosition: AVCaptureDevice.Position? // 카메라 포지션을 저장할 프로퍼티
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    var cameraViewPhotoSize: CameraViewPhotoSize? // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티


    @IBOutlet weak var settingToolbar: UIToolbar! // 화면 비율 버튼이 있는 툴바
    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 비율을 위한 버튼 (1:1, 3:4, 9:16)
    
    var cameraRelatedCoreImageResource: CameraRelatedCoreImageResource? // Video Data Output, Sample Data struct
    
    @IBOutlet weak var photoLibraryButton: UIButton! // 사진앨범 버튼
    @IBOutlet weak var previewView: PreviewView! //
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var blurBGView: UIVisualEffectView!
    @IBOutlet weak var switchButton: UIButton!

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear in CameraViewController")
        
        settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    // UI요소들이 메모리에 올라왔을 때 해야할 것들
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.session = captureSession // TODO 1에서 초기화한 캡쳐세션 -> 프리뷰.세션
        
        sessionQueue.async { // AVCaptureSession을 구성하는건 세션큐에서 할거임
            self.setupSession() // 아래의 extension class 에서 구현
            

            self.startSession()
        }
        setupUI()
        
        
    }
    
    func setupUI() {
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.layer.masksToBounds = true
        photoLibraryButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photoLibraryButton.layer.borderWidth = 1
        
        captureButton.layer.cornerRadius = captureButton.bounds.height/2
        captureButton.layer.masksToBounds = true
        blurBGView.layer.cornerRadius = captureButton.bounds.height/2
        blurBGView.layer.masksToBounds = true
        
    }
    
    
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
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        // TODO: photoOutput의 capturePhoto 메소드
        // orientation
        // photooutput
        
        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            let connection = self.photoOutput.connection(with: .video)
           
            connection?.videoOrientation = videoPreviewLayerOrientation!
            
            // 캡쳐 세션에 요청하는것
            let setting = AVCapturePhotoSettings()
            
            self.photoOutput.capturePhoto(with: setting, delegate: self)
        }
    }
    
    func savePhotoLibrary(image: UIImage) {
        // TODO: capture한 이미지 포토라이브러리에 저장
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // save !
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (_, error) in
                    DispatchQueue.main.async {
                        self.photoLibraryButton.setImage(image, for: .normal)
                    }
                }
            } else {
                print(" error to save photo library")
                // 다시 요청할 수도 있음
                // ...
            }
        }
    }


    @IBOutlet weak var previewConstraints: NSLayoutConstraint!
    
    //MARK: 화면비 변경 버튼
    /*
     previewView에 image를 넣는 변수를 찾아서
     사이즈 변경해주면 될 듯
     이 함수에서 화면비 아이콘도 변경하고 previewView의 사이즈도 변경함.
     !!To do!!
        - preview 사이즈는 변경했는데 실제로 저장되는 사진의 사이즈는 변경하지 못했음.
            -> 화면비 status 상수를 이용해서 저장하기 전에 사이즈 변경해서 저장하는거 해야됨
        - preview 사이즈 변경할 때 지금은 일일이 작성되어있는데
            -> 함수로 묶어서 extention에서 관리하는것도 좋을 것 같음.
     */

    @IBAction func switchScreenRatio(_ sender: Any) {
        print("switchScreenRatio func has called")
        // 0 == 1:1 || 1 == 3:4 || 2 == 9:16
        
        screenRatioSwitchedStatus += 1
        screenRatioSwitchedStatus %= ScreenType.numberOfRatioType()
        if let currentPosition = self.currentPosition {
            switch screenRatioSwitchedStatus {
            case ScreenType.Ratio.square.rawValue :
                print("-> screen_ratio_1_1")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_1")
                previewConstraints.constant
                    = UIScreen.main.bounds.height - UIScreen.main.bounds.width

            case ScreenType.Ratio.retangle.rawValue :
                print("-> screen_ratio_3_4")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_3_4")
                previewConstraints.constant
                    = UIScreen.main.bounds.height - (UIScreen.main.bounds.width) * 4.0 / 3.0
            
            case ScreenType.Ratio.full.rawValue :
                print("-> screen_ratio_9_16")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_9_16")
                previewConstraints.constant = 0
                
            default:
                break;
            }
            // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위함.
            // 이거 필요없으면 나중에 삭제하는게 좋음
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)

            
        }
    }
    
    // MARK:- Get Screen Ratio
    // 이 함수는 extention으로 따로 관리될 수 있음.
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
}


extension CameraViewController {
    // MARK: - Setup session and preview
    
    func setupSession() {
        // TODO: captureSession 구성하기
        // - beginConfiguration
        // - Add Video Input
        // - Add Photo Output
        // - commitConfiguration
        
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        
        // Add video input //
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
                        
            guard let camera = defaultVideoDevice else {
                captureSession.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                self.currentPosition = videoDeviceInput.device.position // 현재 카메라 방향(전or후)

            } else {
                captureSession.commitConfiguration()
                return
            }
        } catch {
            captureSession.commitConfiguration()
            return
        }
        
        // Add photo output //
        photoOutput.setPreparedPhotoSettingsArray(
            [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
            completionHandler: nil
        )
        if captureSession.canAddOutput(photoOutput){
            captureSession.addOutput(photoOutput)
        } else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        // TODO: session Start
        // 특정 쓰레드에서 작업을 수행할거임
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        // TODO: session Stop
        // 특정 쓰레드에서 작업을 수행할거임
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}

extension CameraViewController {
    // MARK: - Save Photo -> Library
    /* 지금은 너무 코드가 더러움... 보기좋게 Constants를 만들고 함수도 extension으로 빼고... 수정할 것!! */
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        // 여기부터 // 더러워지기 시작 // 아랫부분 수정할 것
        var croppedImage: UIImage = image
        
        if( screenRatioSwitchedStatus == 0 ) {
            
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
        // 여기까지 // 정리할 것
        
        //
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
}
