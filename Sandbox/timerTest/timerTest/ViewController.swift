//
//  ViewController.swift
//  timerTest
//
//  Created by 서인재 on 2020/10/20.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var timeLeft: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var timeLeft = 10
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in print("timer fired!")
            
            timeLeft -= 1
            
            self.timeLeft.text = String(timeLeft)
            print(timeLeft)
            
            if(timeLeft==0){
                timer.invalidate()
            }
        }
    }


}
/*
uilable을 만들어서 거기에 카운트 다운을 표시할거다. 아님 택스트 필드를 만들어도 되길 할듯
else if leftNumber < rightNumber {
    rightScore += 1
    rightScoreLabel.text = String(rightScore)

 위 코드를 응용하면된다.
 
 위 코드가 작동하는건, 액션 버튼을 만들거고 그걸 눌렀을때 카운트 다운이 역으로 작동하게 할거다.
 if 문을 이용해서, 3초 5초 10초 만들어야지. 여기에 uiimage업데이트도 같이 해주면 될듯 각 if문 안에다가.
 
 */
