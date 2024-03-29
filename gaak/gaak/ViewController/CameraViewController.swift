//
//  CameraViewController.swift
//  gaak
//
//  Created by Ted Kim on 2020/09/14.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos
import Loaf
import SnapKit
import Haptica



class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {


    // TODO: 초기 설정 1: 카메라 만드는데 필요한 객체들
    // - captureSession
    // - AVCaptureDeviceInput
    // - AVCapturePhotoOutput // Video도 따로 할 수 있음
    // - Queue // 디스패치 큐, 각 기능들이 수행될 때 다른 기능의 수행동작을 막지 않기 위해 사용
    // - AVCaptureDevice DiscoverySession // 폰에서 카메라를 가져올때 도와주는 요소
    var oldPhone: Bool = false //
    var realOldPhone: Bool = false
    let captureSession = AVCaptureSession() // 캡쳐세션을 만들었고
    var captureDevice: AVCaptureDevice? // AVCaptureDevice 객체는 물리적 캡처 장치와 해당 장치와 관련된 속성을 나타냅니다. 캡처 장치를 사용하여 기본 하드웨어의 속성을 구성합니다. 캡처 장치는 또한 AVCaptureSession 객체에 입력 데이터 (예 : 오디오 또는 비디오)를 제공합니다.
    var videoDeviceInput: AVCaptureDeviceInput! // 디바이스 인풋(을 담을 변수 생성, but 아직 카메라가 연결되지는 않음.)
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
        mediaType: .video,
        position: .unspecified
    )
    let motionKit = MotionKit() // core motion 수직수평계(중력가속도)측정을 위한 킷
    
    let ud = UserDefaults.standard // 튜토리얼 및 간단한 유저데이터
    var isLaunched: Bool = false

    var screenRatioSwitchedStatus: Int = 1 // 화면 비율 구분을 위한 저장 프로퍼티
    var currentPosition: AVCaptureDevice.Position? // 카메라 포지션을 저장할 프로퍼티
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    var cameraViewPhotoSize: CameraViewPhotoSize? // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티
    var focusBox: UIView! // 초점 박스
    var assetsFetchResults: PHFetchResult<PHAsset>! // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티-1
    var imageManger: PHCachingImageManager?         // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티-2
    var authorizationStatus: PHAuthorizationStatus? // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티-3
    var timerStatus: Int = 0 // 타이머 0초, 3초, 5초, 10초 구분을 위한 프로퍼티
    var setTime: Int = 0 // 타이머 카운트다운을 위한 프로퍼티
    var countTimer: Timer? // 동적 타이머 프로퍼티를 컨트롤하기 위한 정적 프로퍼티
    var isCounting: Bool = false // 타이머가 동작중인지 확인하는 프로퍼티
    var isOn_flash: Bool = false // 플래시 상태 프로퍼티
    var isOn_Grid = true //그리드 뷰 && 버튼 활성화 비활성화 flow controll value
    var isOn_touchCapture: Bool = false // 터치촬영모드 상태 프로퍼티
    var isOn_continuousCapture: Bool = false // 연속촬영모드 상태 프로퍼티
    var currentAngleH: Float = 0.0 // 현재 "수평H" 각도를 저장하는 프로퍼티
    var currentAngleV: Float = 0.0 // 현재 "수직V" 각도를 저장하는 프로퍼티
    var currentAngleY: Float = 0.0 // 가로모드일 때 "수평H"를 대신하는 프로퍼티
    var tempAngleH: Float = 0.0 // "수평H" 각도핀 고정 -> 임시 기준각도를 저장하는 프로퍼티
    var tempAngleV: Float = 0.0 // "수평V" 각도핀 고정 -> 임시 기준각도를 저장하는 프로퍼티
    var isOn_AnglePin = false // 각도 고정핀 상태
    var pageStatus = 0 // 페이지 컨트롤 인터랙션을 위한 프로퍼티
    let pageSize = 3 // 레이아웃 모드의 개수
    
    var deviceOrientation: Int = 1 // 1: .portrait, 3: .landscapeRight, 4: .landscapeLeft
    
    //OnBording Screen을 위한 프로퍼티
    var tvc: TutorialMasterVC! // 온보드(튜토리얼)뷰 마스터 컨트롤러
    var needTutorial = true // 그냥 닫기버튼을 눌렀을 때 필요한 프로퍼티
    
    //UI 스크롤뷰를 생성하기 위한 프로퍼티
    lazy var scrollView: UIScrollView = {
        // Create a UIScrollView.
        let scrollView = UIScrollView(frame: self.view.frame)
        
        // Hide the vertical and horizontal indicators.
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Allow paging.
        scrollView.isPagingEnabled = true
        
        // Set delegate of ScrollView.
        scrollView.delegate = self
        
        // Specify the screen size of the scroll.
        scrollView.contentSize = CGSize(width: CGFloat(pageSize) * self.layoutView.frame.maxX, height: 0)
        
        return scrollView
    }()
    
    // 페이지 컨트롤
    lazy var pageControl: UIPageControl = {
        // Create a UIPageControl.
        
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0 , width: self.view.frame.width, height:20))
        
        // Set pageControl Properties
        pageControl.isUserInteractionEnabled = true
        pageControl.backgroundColor = UIColor.clear
        if #available(iOS 14.0, *) {
            pageControl.allowsContinuousInteraction = false
        } else {
            // Fallback on earlier versions
        }
        
        // Set the number of pages to page control.
        pageControl.numberOfPages = pageSize
        
        // Set the each pages.
        pageControl.currentPage = 0
        
        // Set the indicators
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 1.0, green: 0.847, blue: 0.0, alpha: 1.0)
        

        var indicators: [UIView] = []
        
        if #available(iOS 14.0, *) {
            indicators = pageControl.subviews.first?.subviews.first?.subviews ?? []
        } else {
            indicators = pageControl.subviews
        }
        
        for (index, indicator) in indicators.enumerated() {
            
            var image: UIImage
            image = UIImage()
            //하단 페이지 컨트롤 이곳에 기본사진, 전신사진, 반신사진 안내를 이미지 형태로 넣어준다
            image = UIImage.init(named: "GuideLineText\(index)")!
            
            if let dot = indicator as? UIImageView {
                dot.image = image
                
            } else {
                let imageView = UIImageView.init(image: image)
                indicator.addSubview(imageView)
                // here you can add some constraints to fix the imageview to his superview
            }
        }
        
        
        
        return pageControl
    }()
    
    // change Layouts with pageControl
    @IBAction func swipeLeft(_ sender: Any) {
        
        // Switch the location of the page. <<<---
        if pageControl.currentPage == 0 || pageControl.currentPage == 1 {
            pageControl.currentPage += 1
            scrollView.setContentOffset(CGPoint(x: pageControl.currentPage * Int(scrollView.frame.maxX), y: 0), animated: true)
            
            // control indicator tint color
            pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 1.0, green: 0.847, blue: 0.0, alpha: 1.0)
            pageControl.pageIndicatorTintColor = .white
            
            // Set pageControl's location
            self.pageControl.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(self.view).offset(-60 * pageControl.currentPage)
                
                if realOldPhone { make.bottom.equalTo(self.cameraToolsView).inset(147) }
                else { make.bottom.equalTo(self.cameraToolsView).inset(155) }
                make.height.equalTo(20)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // change Layouts with pageControl
    @IBAction func swipeRight(_ sender: Any) {
        
        // Switch the location of the page. --->>>
        
        if pageControl.currentPage == 2 || pageControl.currentPage == 1 {
            pageControl.currentPage -= 1
            scrollView.setContentOffset(CGPoint(x: pageControl.currentPage * Int(scrollView.frame.maxX), y: 0), animated: true)
            
            // control indicator tint color
            pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 1.0, green: 0.847, blue: 0.0, alpha: 1.0)
            
            pageControl.pageIndicatorTintColor = .white
            
            // Set pageControl's location
            self.pageControl.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(self.view).offset(-60 * pageControl.currentPage)
                if realOldPhone { make.bottom.equalTo(self.cameraToolsView).inset(147) }
                else { make.bottom.equalTo(self.cameraToolsView).inset(155) }
                make.height.equalTo(20)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    // 상단 툴 바
    @IBOutlet weak var settingToolbar: UIToolbar! // 화면 비율 버튼이 있는 툴바
    @IBOutlet weak var settingToolbarHeight: NSLayoutConstraint! // 셋업 툴바 height 셋업
    @IBOutlet weak var moreView: UIView! // 더보기 뷰(활성화/비활성화)
    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 비율을 위한 버튼 (1:1, 3:4, 9:16)
    @IBOutlet weak var switchButton: UIButton! // 카메라 전환 버튼
    @IBOutlet weak var timerButton: UIButton! // 타이머, 더보기에 있는 버튼 이미지
    @IBOutlet weak var timeLeft: UILabel! // 타이머, 동작할 때 화면중앙에 남은 시간 안내
    @IBOutlet weak var flashButton: UIButton! // 플래시 on/off 버튼
    @IBOutlet weak var touchCaptureButton: UIButton! // 터치촬영 on/off 버튼
    @IBOutlet weak var continuousCaptureButton: UIButton!// 연속촬영 버튼
    @IBOutlet weak var blindView: UIView!
    
    // 화면 중앙에 위치한 기능들
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var previewViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gridviewView: GridView!
    @IBOutlet weak var gridButton: UIButton! // 그리드 버튼
    @IBOutlet weak var gridViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gridH1: NSLayoutConstraint!
    @IBOutlet weak var gridH2: NSLayoutConstraint!
    @IBOutlet weak var gridV1: NSLayoutConstraint!
    @IBOutlet weak var gridV2: NSLayoutConstraint!
    @IBOutlet weak var layoutView: UIView! // 레이아웃 뷰
    @IBOutlet weak var skyShotOuter: UIImageView! // 항공샷 기준점 (기준각도)
    @IBOutlet weak var skyShotInner: UIImageView! // 항공샷 인디케이터(각도 표시기)

    @IBOutlet weak var layoutViewHeight: NSLayoutConstraint!
    
    // 하단 툴 바
    @IBOutlet weak var cameraToolsView: UIView! // 화면 하단의 툴 바
    @IBOutlet weak var photosButton: UIButton! // 사진촬영 버튼
    @IBOutlet weak var horizonIndicator: UIView! // 수평계(회전할 superview)
    @IBOutlet weak var captureButtonInner: UIImageView! // 캡쳐버튼 회전하는 객체
    @IBOutlet weak var captureButtonOuter: UIImageView! // 캡쳐버튼 테두리
    @IBOutlet weak var horizonIndicatorInner: UIImageView! // 회전하는 객체
    @IBOutlet weak var horizonIndicatorOuter: UIImageView! // 수평 100%
    @IBOutlet weak var anglePinStatus: UIImageView! // 각도고정핀 활성화 상태표시
    @IBOutlet weak var anglePin: UIView! // 각도 고정핀 회전을 위한 프로퍼티
    @IBOutlet weak var captureButtonView: UIView!
    

    override var prefersStatusBarHidden: Bool {
        return true // 아이폰 상단 정보 (시간, 배터리 등)을 숨겨줌
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true // Awake Screen!
        
        previewView.session = captureSession
        sessionQueue.async { // AVCaptureSession을 구성하는건 세션큐에서 할거임
            self.setupSession()
            // self.startSession()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tvc = TutorialMasterVC() // 튜토리얼마스터VC 클래스
        
        navigationController?.isNavigationBarHidden = true // 네비게이션 바 비활성화를 미리 해줘야 함
        
        startSession() // 카메라 기능 활성화
        setGravityAccelerator() // 각도 기능 활성화
        
    }
    
//    var feedbackGenerator: UINotificationFeedbackGenerator?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //OnBording Screen을 실행
        self.checkTutorial()
        
        /* 노치가 있는 폰에서는 safeArea를 고려해서 UI를 배치해야하는데
         viewDidAppear 에서부터 safeArea를 선언할 수 있음. */
        setupUI()
        
//        setupHapticGenerator()
    }
//
//    private func setupHapticGenerator(){
//        print("setupHapticGenerator has called")
//        self.feedbackGenerator = UINotificationFeedbackGenerator()
//        self.feedbackGenerator?.prepare()
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopSession() // 카메라 기능 멈춤
        motionKit.stopDeviceMotionUpdates() // 각도기능 멈춤

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("didReceiveMemotyWarning")
        // Dispose of any resources that can be recreated
    }
    
    
    //MARK: setupUI()
    func setupUI() {
        oldPhone = self.view.frame.width/self.view.frame.height > 0.5 ? true : false
        realOldPhone = self.view.frame.height < 700 ? true : false
        navigationController?.isNavigationBarHidden = true
        
        
        moreView.isHidden = true // 더보기(상단툴바) 버튼 UI 설정 // 안 보이게 해놓고
        
        setLatestPhoto() // 앨범버튼 썸네일 설정
        
        setToolbarsUI() // 상, 하단 툴 바 설정
        
        setLayoutMode() // 레이아웃(사진가이드) 뷰 설정
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
            /// defaultVideoDevice -> captureDevice
            //var defaultVideoDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                captureDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                captureDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                captureDevice = frontCameraDevice
            }
                        
            guard let camera = captureDevice else {
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
    
    // MARK: OnBoarding Tutorial 실행여부 확인
    func checkTutorial() {

        if ud.bool(forKey: UserInfoKey.tutorial) == false && needTutorial == true {
            needTutorial = false
            tvc.modalPresentationStyle = .fullScreen
            
            self.present(tvc!, animated: false)
        }
    }
}

/* MARK: 레이아웃 모드 */
// ScrollView, PageControll
extension CameraViewController: UIScrollViewDelegate {
    
    // 코드 수행시간 측정
    public func measureTime(_ closure: () -> ()) -> TimeInterval {
        let startDate = Date()
        closure()
        return Date().timeIntervalSince(startDate)
    }
}
