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
    
    var screenRatioSwitchedStatus: Int = 1 // 화면 비율 구분을 위한 저장 프로퍼티
    var currentPosition: AVCaptureDevice.Position? // 카메라 포지션을 저장할 프로퍼티
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    var cameraViewPhotoSize: CameraViewPhotoSize? // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티
    
    var assetsFetchResults: PHFetchResult<PHAsset>! // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티 3종 세트-1
    var imageManger: PHCachingImageManager? // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티 3종 세트-2
    var authorizationStatus: PHAuthorizationStatus? // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티 3종 세트-3

    // 상단 툴 바
    @IBOutlet weak var settingToolbar: UIToolbar! // 화면 비율 버튼이 있는 툴바
    @IBOutlet weak var settingToolbarHeight: NSLayoutConstraint! // 셋업 툴바 height 셋업
    @IBOutlet weak var moreView: UIView! // 더보기 뷰(활성화/비활성화)
    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 비율을 위한 버튼 (1:1, 3:4, 9:16)
    @IBOutlet weak var switchButton: UIButton! // 카메라 전환 버튼

    // 화면 중앙에 위치한 기능들
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var previewViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gridViewHeight: NSLayoutConstraint!
    
    // lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    //이거 필요없음 시바

    // 하단 툴 바
    @IBOutlet weak var cameraToolBarHeight: NSLayoutConstraint! // 카메라 툴바 height 셋업
    @IBOutlet weak var cameraToolbar: UIToolbar! // 화면 하단의 툴 바
    @IBOutlet weak var photoLibraryButton: UIButton! // 사진앨범 버튼
    @IBOutlet weak var captureButton: UIButton!// 사진촬영 버튼
        
    
    //그리드 뷰 && 버튼 활성화 비활성화
    //버튼 크기 조정이 필요할것 같습니다. 터치미스가 잘나는데, 버튼 크기조절 고민필요!
    //현재는 어플을 키면 바로 격자가 on상태인데, 최종완성시에는 사용성에따라 off로 할지 on으로 할지 고민필요함
    @IBOutlet weak var gridH1: NSLayoutConstraint!
    @IBOutlet weak var gridH2: NSLayoutConstraint!
    @IBOutlet weak var gridV1: NSLayoutConstraint!
    @IBOutlet weak var gridV2: NSLayoutConstraint!
    var isOn = true
    @IBOutlet weak var gridButton: UIButton! // 그리드 버튼
    @IBOutlet weak var gridviewView: GridView!
    @IBAction func gridButton(_ sender: Any) {
        isOn = !isOn
        if isOn {
            gridviewView.isHidden = false
            gridButton.setImage(UIImage(named: "onGrid" ), for: .normal)
        } else {
            gridviewView.isHidden = true
            gridButton.setImage(UIImage(named: "offGrid"), for: .normal)
        }
    }
    
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true // 아이폰 상단 정보 (시간, 배터리 등)을 숨겨줌
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.session = captureSession
        
        sessionQueue.async { // AVCaptureSession을 구성하는건 세션큐에서 할거임
            self.setupSession()
            self.startSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    

    //MARK: setupUI()
    func setupUI() {
        
        
                
        // 더보기(상단바) 버튼 UI 설정
        moreView.isHidden = true // 안 보이게 해놓고
        
        // 하단 툴바
        cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        //photoLibraryButton.setImage(UIImage(named: "?"), for: .normal) // image
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.layer.masksToBounds = true
        photoLibraryButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photoLibraryButton.layer.borderWidth = 1
        
        captureButton.layer.cornerRadius = captureButton.bounds.height/2
        captureButton.layer.masksToBounds = true
        
        setLatestPhoto() // 앨범버튼 썸네일 설정
        setToolbarsUI() // 상, 하단 툴 바 설정

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

/* 인재님이 구현한 함수 넣는 곳 */
extension CameraViewController {
    
    //MARK: 그리드를 그리는 함수
    func addGridView() {
        // grideView is my view where you want to show the grid view
        let horizontalMargin = gridviewView.bounds.size.width / 4
        let verticalMargin = gridviewView.bounds.size.height / 4

        let gridView = GridView()

        gridView.translatesAutoresizingMaskIntoConstraints = false

        gridviewView.addSubview(gridView)

        gridView.backgroundColor = UIColor.clear
        gridView.leftAnchor.constraint(equalTo: previewView.leftAnchor, constant: horizontalMargin).isActive = true
        gridView.rightAnchor.constraint(equalTo: previewView.rightAnchor, constant: -1 * horizontalMargin).isActive = true
        gridView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: verticalMargin).isActive = true
        gridView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -1 * verticalMargin).isActive = true

    }
}
