//
//  ViewController.swift
//  OnBoardScreenTed
//
//  Created by Ted Kim on 2020/11/12.
//

import Foundation
import UIKit

class CameraViewController: UIViewController {
    
    var first: UITextView!
    
    var tvc: TutorialMasterVC! // 온보드(튜토리얼)뷰 마스터 컨트롤러
    var needTutorial = true // 그냥 닫기버튼을 눌렀을 때 필요한 프로퍼티
    
    override func viewDidLoad() {
        
        first = UITextView()
        first.text = "Here is the CameraViewController !"
        first.textColor = .black
        first.frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 100)
        first.textAlignment = .center
        view.addSubview(first)
        
        tvc = TutorialMasterVC() // 튜토리얼마스터VC 클래스
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.checkTutorial()
    }
    
    func checkTutorial() {
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false && needTutorial == true {
            print("before ud=\(ud.bool(forKey: UserInfoKey.tutorial))")
            needTutorial = false
            tvc.modalPresentationStyle = .fullScreen
            
            self.present(tvc!, animated: false)
        }
    }
}
