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

class CameraViewController: UIViewController {
    // TODO: 초기 설정 1: 카메라 만드는데 필요한 객체들
    // - captureSession
    // - AVCaptureDeviceInput
    // - AVCapturePhotoOutput // Video도 따로 할 수 있음
    // - Queue // 디스패치 큐
    // - AVCaptureDevice DiscoverySession // 폰에서 카메라를 가져올때 도와주는 요소
    
    let captureSession = AVCaptureSession() // 캡쳐세션을 만들었고
    var videoDeviceInput: AVCaptureDeviceInput! // 디바이스 인풋, but 카메라가 연결되지는 않음.
    let photoOutput = AVCapturePhotoOutput()
    
    let sessionQueue = DispatchQueue(label: "session Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
        mediaType: .video,
        position: .unspecified
    )
    

    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var blurBGView: UIVisualEffectView!
    @IBOutlet weak var switchButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 초기 설정 2: UI요소들이 메모리에 올라왔을 때 해야할 것들
        
        previewView.session = captureSession // TODO 1에서 초기화한 캡쳐세션을 프리뷰로
        
        // AVCaptureSession을 구성하는건 세션큐에서 할거임
        sessionQueue.async {
            self.setupSession() // 아래의 extension CameraViewController 에서 구현
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
        // TODO: 카메라는 1개 이상이어야함
        
        
        // TODO: 반대 카메라 찾아서 재설정
        
    }
    
    func updateSwitchCameraIcon(position: AVCaptureDevice.Position) {
        // TODO: Update ICON
        
        
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        // TODO: photoOutput의 capturePhoto 메소드


    }
    
    
    func savePhotoLibrary(image: UIImage) {
        // TODO: capture한 이미지 포토라이브러리에 저장
    }
}


extension CameraViewController {
    // MARK: - Setup session and preview
    func setupSession() {
        // TODO: captureSession 구성하기
        // - presetSetting 하기
        // - beginConfiguration
        // - Add Video Input
        // - Add Photo Output
        // - commitConfiguration
        

        
        
    }
    
    
    
    func startSession() {
        // TODO: session Start

    }
    
    func stopSession() {
        // TODO: session Stop
        
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        
        
    }
}
