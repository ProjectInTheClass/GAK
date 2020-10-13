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
    var cameraRelatedCoreImageResource: CameraRelatedCoreImageResource? // Video Data Output, Sample Data struct

    @IBOutlet weak var previewView: PreviewView! //


    @IBOutlet weak var settingToolbar: UIToolbar! // 화면 비율 버튼이 있는 툴바
    @IBOutlet weak var cameraToolbar: UIToolbar! // 화면 하단의 툴 바
    
    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 비율을 위한 버튼 (1:1, 3:4, 9:16)
    
    @IBOutlet weak var switchButton: UIButton!

    @IBOutlet weak var photoLibraryButton: UIButton! // 사진앨범 버튼
    @IBOutlet weak var captureButton: UIButton!
    
    
    override var prefersStatusBarHidden: Bool {
        return true // 아이폰 상단 정보 (시간, 배터리 등)을 숨겨줌
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear in CameraViewController")
        //navigationController?.isNavigationBarHidden = true
        
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
    
    
    //MARK: 카메라 전환 아이콘 변경
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
    //MARK: 카메라 전후 전환
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
                        //self.photoLibraryButton.setImage(image, for: .normal)
                        // 주석이유: 사진촬영->앨범탐색->다시촬영모드로돌아왔을때
                        // 앨범버튼의 width가 view.width와 동일해짐.
                    }
                }
            } else {
                print(" error to save photo library")
                // 다시 요청할 수도 있음
                // ...
            }
        }
    }


    
    
    //MARK: 화면비 변경 버튼
    /*
     이 함수에서 화면비 아이콘도 변경하고 previewView의 사이즈도 변경함.
     !!To do!!
        - preview 사이즈 변경할 때 지금은 previewConstraints.constant가
           지저분하게 작성되어있는데, 깔끔하게 정리할 필요가 있음.
     */
    @IBOutlet weak var previewConstraints: NSLayoutConstraint!
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
                
                cameraToolbar.isTranslucent = false

            case ScreenType.Ratio.retangle.rawValue :
                print("-> screen_ratio_3_4")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_3_4")
                previewConstraints.constant
                    = UIScreen.main.bounds.height - (UIScreen.main.bounds.width) * 4.0 / 3.0
            
            case ScreenType.Ratio.full.rawValue :
                print("-> screen_ratio_9_16")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_9_16")
                previewConstraints.constant = 0
                
                
                cameraToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
                cameraToolbar.isTranslucent = true
            default:
                break;
            }
            // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위함.
            // 이거 필요없으면 나중에 삭제하는게 좋음
            // extension으로 빼놨음.
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)

            
        }
    }
}



/* 본 extension에서는 ViewDidLoad에서 사용되는 함수들을 정의해놓았음.
   setupSeesion(), startSession(), setupUI() 함수들이 사용됨.
   환경을 셋업하고 preview로 output(jpeg)로 보여주는 작업들을 수행함. */
extension CameraViewController {
    // MARK: SetupSession + preview
    
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
        //
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
    
    func setupUI() {
        
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.layer.masksToBounds = true
        photoLibraryButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photoLibraryButton.layer.borderWidth = 1
        
        captureButton.layer.cornerRadius = captureButton.bounds.height/2
        captureButton.layer.masksToBounds = true

        settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        settingToolbar.isTranslucent = true
        
        cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

    }
    
}
