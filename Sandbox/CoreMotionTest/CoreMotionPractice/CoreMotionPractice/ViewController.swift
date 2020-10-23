//
//  ViewController.swift
//  CoreMotionPractice
//
//  Created by Ted Kim on 2020/10/23.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionKit = MotionKit()
    
    @IBOutlet weak var captureButton: UIImageView!
    @IBOutlet weak var captureButtonOutline: UIImageView!
    @IBOutlet weak var RightLeft: UIView!
    
    @IBOutlet weak var RightLeftInner: UIImageView!
    @IBOutlet weak var RightLeftOutline: UIImageView!
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재로부터 얼마나 움직이는지 체크할때? 활용법 아직 잘 모름
//        motionKit.getAttitudeFromDeviceMotion(interval: 0.1) {
//
//            let x = Float(10^3) // 몇 째 자리인지 구하는 변수
//
//            let pitch = Float($0.pitch)
//            let yaw = Float($0.yaw)
//
//            let roundedPitch = round(pitch * x) / x
//            let roundedYaw = round(yaw * x) / x
//
//            print("pitch: \(roundedPitch)")
//            print("yaw: \(roundedYaw)")
//        }
        
        motionKit.getGravityAccelerationFromDeviceMotion(interval: 0.1) { (x, y, z) in
            
            let roundedX = Float(round(x * 100)) / 100.0
            //let roundedY = Float(round(y * 100)) / 100.0
            let roundedZ = Float(round(z * 100)) / 100.0
            
            // x가 좌-1 우+1
            // z가 앞-1 뒤+1
            
            //self.RL.constant = CGFloat(roundedX * 100)
            
            var current: Float
            var transform: CATransform3D
            
            current = roundedX * 200
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(current * Float.pi / 180), 0, 0, 1
            )
            UIView.animate(withDuration: 0.1) {
                self.RightLeft.transform3D = transform
            }
            
            if (current < 5 && current > -5) {
                self.RightLeftInner.tintColor = .green
                self.RightLeftOutline.tintColor = .green
            }
            else {
                self.RightLeftInner.tintColor = .red
                self.RightLeftOutline.tintColor = .red
            }
            
            ///
            current = roundedZ * 100
            
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(current * Float.pi / 180), 1, 0, 0
            )
            UIView.animate(withDuration: 0.1) {
                self.captureButton.transform3D = transform
            }
            
            if (current < 5 && current > -5) {
                self.captureButton.alpha = 1.0
                self.captureButton.tintColor = .green
                self.captureButtonOutline.tintColor = .green
            }
            else {
                self.captureButton.alpha = CGFloat(-abs(current/90))+1.0
                self.captureButton.tintColor = .red
                self.captureButtonOutline.tintColor = .red
            }
            
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

