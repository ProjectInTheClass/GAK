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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    let sessionQueue = DispatchQueue(label: "session Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
        mediaType: .video,
        position: .unspecified
    )
    // TODO: 초기 설정 1: 카메라 만드는데 필요한 객체들
    // - captureSession
    // - AVCaptureDeviceInput
    // - AVCapturePhotoOutput // Video도 따로 할 수 있음
    // - Queue // 디스패치 큐, 각 기능들이 수행될 때 다른 기능의 수행동작을 막지 않기 위해 사용
    // - AVCaptureDevice DiscoverySession // 폰에서 카메라를 가져올때 도와주는 요소
    
    var captureDevice: AVCaptureDevice? // AVCaptureDevice 객체는 물리적 캡처 장치와 해당 장치와 관련된 속성을 나타냅니다. 캡처 장치를 사용하여 기본 하드웨어의 속성을 구성합니다. 캡처 장치는 또한 AVCaptureSession 객체에 입력 데이터 (예 : 오디오 또는 비디오)를 제공합니다.
    
    var captureSession: AVCaptureSession? // 입력장치에서 출력으로의 데이터 흐름을 조정하는 AVCaptureSession 객체

    var videoDeviceInput: AVCaptureDeviceInput! // 디바이스 인풋(을 담을 변수 생성, but 아직 카메라가 연결되지는 않음.)
    var photoOutput: AVCapturePhotoOutput? // 스틸 사진과 관련된 대부분의 캡처 워크 플로에 대한 최신 인터페이스를 제공하는 AVCaptureOutput의 구체적인 하위 클래스입니다.
    
    var videoDataOutput: AVCaptureVideoDataOutput? // AVCaptureVideoDataOutput은 캡처중인 비디오에서 압축되지 않은 프레임을 처리하거나 압축 된 프레임에 액세스하는 데 사용하는 AVCaptureOutput의 구체적인 하위 클래스입니다. AVCaptureVideoDataOutput 인스턴스는 다른 미디어 API를 사용하여 처리 할 수있는 비디오 프레임을 생성합니다. captureOutput (_ : didOutputSampleBuffer : from :)
    
    var settingsForMonitoring: AVCapturePhotoSettings? // 단일 사진 캡처 요청에 필요한 모든 기능과 설정을 설명하는 변경 가능한 객체입니다.

    
    var cameraRelatedCoreImageResource: CameraRelatedCoreImageResource? // Video Data Output, Sample Data struct

    
    var photoMode: AddPhotoMode? // 카메라, 사진앨범 모드인지 구분하는 저장 프로퍼티
    var cameraFlashSwitchedStatus: Int = 0 // FlashMode 구분을 위한 저장 프로퍼티
    var cameraPosition: AVCaptureDevice.Position? // 카메라 포지션을 저장할 프로퍼티 .back, .front
    var context: CIContext? // openGL ES3 api를 사용하여 CGImage를 생성하기 위함. iOS7, 3gs, 아이팟터치 3세대 이후 지원하며 3D 라이브러리 중 하나이다. (OpenGL ES (임베디드 단말을 위한 OpenGL)는 크로노스 그룹이 정의한 3차원 컴퓨터 그래픽스 API인 OpenGL의 서브셋으로, 휴대전화, PDA 등과 같은 임베디드 단말을 위한 API이다.) 참고blog:https://atelier-chez-moi.tistory.com/53

    var authorizationStatus: AVAuthorizationStatus? // Camera 접근 권한을 위한 저장 프로퍼티

    
    var screenRatioSwitchedStatus: Int = 0 // 화면 비율 구분을 위한 저장 프로퍼티
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    var cameraViewPhotoSize: CameraViewPhotoSize? // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티


    @IBOutlet weak var settingToolbar: UIToolbar! // 화면 비율 버튼이 있는 툴바
    

    @IBOutlet weak var photoLibraryButton: UIButton! // 사진앨범 버튼
    @IBOutlet weak var previewView: PreviewView! //
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var blurBGView: UIVisualEffectView!
    @IBOutlet weak var switchButton: UIButton!

    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 비율을 위한 버튼 (1:1, 3:4, 9:16)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // UI요소들이 메모리에 올라왔을 때 해야할 것들
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init Setting
        
        photoMode = .camera
        cameraFlashSwitchedStatus = FlashModeConstant.off.rawValue
        cameraPosition = .back // default는 back camera
        screenRatioSwitchedStatus = 0 // 1:1 Ratio
        
        if let cameraPosition = cameraPosition {
            // 초기 셋팅, back camera and 1:1 ratio
            // cameraPosition = .back
            // screenRatioSwitchedStatus = 0 //square
            getSizeByScreenRatio(with: cameraPosition, at: screenRatioSwitchedStatus)
        }
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        videoDataOutput = AVCaptureVideoDataOutput()
        
        // openGL ES3 로 이미지를 렌더링할 context 생성
        // About OpenGL ES - https://developer.apple.com/library/prerelease/content/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008793
        // About Core Image - https://developer.apple.com/library/prerelease/content/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185
        
        context = CIContext()
        
        cameraRelatedCoreImageResource = CameraRelatedCoreImageResource()

//        sessionQueue.async {
//            self.setupSession() // 아래의 extension CameraViewController 에서 구현
//            self.startSession()
//        }
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in CameraViewController")
        
        // toolbar hide
        navigationController?.isToolbarHidden = true
        
        // navigationbar hide
        navigationController?.navigationBar.isHidden = true
        
        // MARK: Camera tool bar 만들면 활성화 할 것
        // cameraToolbar, settingToolbar transparent
    //  -->cameraToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    //  -->cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        // Camera Permission 체크
        checkCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in CameraViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in CameraViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in CameraViewController")
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
            self.cameraPosition = currentVideoDevice.position
            let isFront = self.cameraPosition == .front
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
                    self.captureSession?.beginConfiguration()
                    self.captureSession?.removeInput(self.videoDeviceInput)

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
    
    // MARK: 사진 촬영, 저장
    @IBAction func capturePhoto(_ sender: UIButton) {
        // orientation
        // photooutput

        
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if let authorizationStatusOfCamera = authorizationStatus {
            
            print("authorizationStatusOfCamera.rawValue: \(authorizationStatusOfCamera.rawValue)")
            
            switch authorizationStatusOfCamera {
            case .authorized:
                settingsForMonitoring = AVCapturePhotoSettings()
                
                DispatchQueue.main.async {
                    guard let photoCaptureSetting = self.settingsForMonitoring,
                          let capturePhotoOutput = self.photoOutput
                    else { return }
                    
                    let previewPixelType = photoCaptureSetting.availablePreviewPhotoPixelFormatTypes.first!
                    let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                         kCVPixelBufferWidthKey as String: 160,
                                         kCVPixelBufferHeightKey as String: 160]
                    photoCaptureSetting.previewPhotoFormat = previewFormat
                    
                    // photoCaptureSetting.flashMode = (?) // 플래쉬 구현 후 작성필요
                    // photoCaptureSetting.isAutoStillImageStabilizationEnabled = true // deprecated
                    
                    // 활성 자치 및 형식에서 지원하는 최고 해상도로 스틸 이미지를 캡쳐할 지 여부를 지정함. default == false
                    photoCaptureSetting.isHighResolutionPhotoEnabled = false
                    
                    capturePhotoOutput.capturePhoto(with: photoCaptureSetting, delegate: self)
                }
                
            case .denied:
                print(authorizationStatusOfCamera)
                showNotice(alertCase: .camera)
            default:
                return
            }
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

    //MARK: 화면비 변경 버튼
    @IBAction func switchScreenRatio(_ sender: Any) {
        print("func switchScreenRatio has called")
        // 0 == 1:1 || 1 == 3:4 || 2 == 9:16
        screenRatioSwitchedStatus += 1
        screenRatioSwitchedStatus %= ScreenType.numberOfRatioType()
        if let currentPosition = cameraPosition {
            switch screenRatioSwitchedStatus {
            case ScreenType.Ratio.square.rawValue :
                print("-> screen_ratio_1_1")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_1")
            case ScreenType.Ratio.retangle.rawValue :
                print("-> screen_ratio_3_4")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_3_4")
            
            case ScreenType.Ratio.full.rawValue :
                print("-> screen_ratio_9_16")
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_9_16")
                
            default:
                break;
            }
            // 전후면 카메라 스위칭 될 때, 화면 비율을 넘기기 위함.
            getSizeByScreenRatio(with: currentPosition, at: screenRatioSwitchedStatus)
        }
    }
    
}


//extension CameraViewController {
//    // MARK: - Setup session and preview
//
//    func setupSession() {
//        // TODO: captureSession 구성하기
//        // - beginConfiguration
//        // - Add Video Input
//        // - Add Photo Output
//        // - commitConfiguration
//
//        captureSession?.sessionPreset = .photo
//        captureSession?.beginConfiguration()
//
//        // Add video input //
//        do {
//            var defaultVideoDevice: AVCaptureDevice?
//            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
//                defaultVideoDevice = dualCameraDevice
//            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//                defaultVideoDevice = backCameraDevice
//            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//                defaultVideoDevice = frontCameraDevice
//            }
//
//            guard let camera = defaultVideoDevice else {
//                captureSession.commitConfiguration()
//                return
//            }
//
//            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
//
//            if captureSession.canAddInput(videoDeviceInput) {
//                captureSession.addInput(videoDeviceInput)
//                self.videoDeviceInput = videoDeviceInput
//                cameraPosition = videoDeviceInput.device.position // 현재 카메라 방향(전or후)
//
//            } else {
//                captureSession.commitConfiguration()
//                return
//            }
//        } catch {
//            captureSession.commitConfiguration()
//            return
//        }
//
//        // Add photo output //
//        photoOutput.setPreparedPhotoSettingsArray(
//            [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
//            completionHandler: nil
//        )
//        if captureSession.canAddOutput(photoOutput){
//            captureSession.addOutput(photoOutput)
//        } else {
//            captureSession.commitConfiguration()
//            return
//        }
//        captureSession.commitConfiguration()
//    }
//
//    func startSession() {
//        // TODO: session Start
//        // 특정 쓰레드에서 작업을 수행할거임
//        sessionQueue.async {
//            if !self.captureSession.isRunning {
//                self.captureSession.startRunning()
//            }
//        }
//    }
//
//    func stopSession() {
//        // TODO: session Stop
//        // 특정 쓰레드에서 작업을 수행할거임
//        sessionQueue.async {
//            if self.captureSession.isRunning {
//                self.captureSession.stopRunning()
//            }
//        }
//    }
//}

extension CameraViewController {
    // MARK: - Save Photo -> Library

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        // 여기서 촬영될 때 화면비대로 잘라줘야할 것 같음.
        // 아래의 self.savePhotoLibrary 에 들어가는 파라미터 image를 잘라주면 될 듯
//
//        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1080, height: 1920))
//        let cgImgae = image.cgImage
//        guard let croppedCGImage = cgImgae?.cropping(to: rect) else {return}
//        self.savePhotoLibrary(image: UIImage(cgImage: croppedCGImage))
//
//        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1080, height: 1920))
//        //let scale = .frame.width/image.size.width
//
//        guard let croppedimage = cropImage2(image: image, rect: rect, scale: 1.0) else { return }
//        self.savePhotoLibrary(image: croppedimage)
        
        
        self.savePhotoLibrary(image: image)
        
    }
    
// test cropping
    func cropImage2 (image : UIImage, rect : CGRect, scale : CGFloat)-> UIImage? {
        UIGraphicsBeginImageContextWithOptions (
            CGSize (width : rect.size.width / scale, height : rect.size.height / scale), true, 0.0)
        image.draw (at : CGPoint (x : -rect.origin.x / scale, y : -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext ()
        return croppedImage
    }
}

extension UIImage {
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
}
