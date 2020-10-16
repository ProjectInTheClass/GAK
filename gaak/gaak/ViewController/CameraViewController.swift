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
        
        //print("viewWillAppear in CameraViewController")
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: 사진 촬영
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
    
    //MARK: 사진 저장
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
                        // 주석이유(bug): 사진촬영->앨범탐색->다시촬영모드로돌아왔을때
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
            // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위함.
            // 이거 필요없으면 나중에 삭제하는게 좋음
            // extension으로 빼놨음.
            setToolbarsUI()
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)
        }
    }
    
    //MARK: 툴바 크기 셋업
    @IBOutlet weak var previewViewTop: NSLayoutConstraint!
    @IBOutlet weak var cameraToolBarHeight: NSLayoutConstraint!
    
    // @IBOutlet weak var previewConstraints: NSLayoutConstraint!
    func setToolbarsUI(){
        switch screenRatioSwitchedStatus {
        case ScreenType.Ratio.square.rawValue :
            print("-> UI setup: screen_ratio 1_1")
            
            // setToolbarsUI // tool bar UI 설정하는 부분
            settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            settingToolbar.isTranslucent = false
            cameraToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            cameraToolbar.isTranslucent = false
            
            cameraToolBarHeight.constant = view.frame.size.height - (view.frame.size.width + settingToolbar.frame.size.height)
        
        case ScreenType.Ratio.retangle.rawValue :
            print("-> UI setup: screen_ratio 3_4")
            
            settingToolbar.isTranslucent = true
            cameraToolbar.isTranslucent = false
            
            cameraToolBarHeight.constant = view.frame.size.height - ((view.frame.size.width)*(4.0/3.0))
            
        case ScreenType.Ratio.full.rawValue :
            print("-> UI setup: screen_ratio 9:16")

            settingToolbar.isTranslucent = true
            cameraToolbar.isTranslucent = true
            
            cameraToolBarHeight.constant = view.frame.size.height - ((view.frame.size.width)*(4.0/3.0))


        default:
            print("--> screenRatioSwitchedStatus: default")
        }
    }
    
    // setupUI()
    func setupUI() {
        
        setToolbarsUI()
        
        // 상단 툴바
        
        // settingToolbar.isTranslucent = true
        
        
        // 하단 툴바
        cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.layer.masksToBounds = true
        photoLibraryButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photoLibraryButton.layer.borderWidth = 1
        
        captureButton.layer.cornerRadius = captureButton.bounds.height/2
        captureButton.layer.masksToBounds = true
    }
    
    // MARK:- Get Screen Ratio
    // AVCaptureDevice 종류와 선택한 스크린 사이즈 비율에 맞게 PreviewImageView Frame 변경
    /// 이 함수는 호출되지만, 함수에서 변경된 contants는 사용되지 않음.
    /// 나중에 시간있으면 코드정리할 때, 이 함수를 사용해여 객체지향프로그래밍을 구현할 것.
    /// -> 귀찮아서 사용 안 하는중...
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
}

extension CameraViewController {
    
    
    
}
