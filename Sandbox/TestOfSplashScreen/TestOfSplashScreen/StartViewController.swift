//
//  StartViewController.swift
//  TestOfSplashScreen
//
//  Created by 서인재 on 2020/11/12.
//

import Foundation
import UIKit
class StartViewController: UIViewController {
    
    var tvc: TutorialMasterVC!
    var first: UITextView!
    
    override func viewDidLoad() {
        
        first = UITextView()
        first.text = "first screen"
        first.textColor = .black
        first.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        view.addSubview(first)
        
        tvc = TutorialMasterVC()
    }
    
    func checkFirstRun() {
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            print("before ud=\(ud.bool(forKey: UserInfoKey.tutorial))")
            
            tvc.modalPresentationStyle = .fullScreen
            self.present(tvc!, animated: false)
        }
    }
}
