//
//  ViewController.swift
//  timerTest
//
//  Created by 서인재 on 2020/10/20.
//

import UIKit
import Foundation

var countSwitchedStatus: Int = 0 // 타이머 0초, 3초, 5초, 10초 구분을 위한 프로퍼티
var setTime: Int = 0


class ViewController: UIViewController {

    @IBOutlet weak var timerButton: UIImageView!
    @IBOutlet weak var timeLeft: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func timerButton(_ sender: Any) {
        
        countSwitchedStatus += 1
        countSwitchedStatus %= 4
                
        switch countSwitchedStatus {
        case 0:
            setTime = 0
            timerButton.image = UIImage(named: "timer0")
            timeLeft.isHidden = true
        case 1:
            setTime = 3
            timerButton.image = UIImage(named: "timer3")
            timeLeft.isHidden = false
        case 2:
            setTime = 5
            timerButton.image = UIImage(named: "timer5")
        case 3:
            setTime = 10
            timerButton.image = UIImage(named: "timer10")

        default:
            break
        }
        
        
    }
    
    @IBAction func touchedStartTimerButton(_ sender: Any) {
        //off(default) == 0 || 3초 == 1 || 5초 == 2 || 10초 == 3
        
        //아래 코드를 함수화 할 수 있나??? 케이스문에 각각 넣으면 너무 하드 코딩이됨
        var countDown = setTime + 2
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            countDown -= 1
            
            self.timeLeft.text = String(countDown-1)
            
            if(countDown == 1){
                
                timer.invalidate()

                // 사진 캡쳐를 추가한다 || 로 하면되지 않을까?
//                print("capture photo !")
                // 여기서 capturePhoto() 를 호출합니다.

            }
            
        }
    }
}


//countSwitchedStatus += 1 // 이것도 0부터 시작하게 해야하는데... 버튼을 한번 누루면 자동으로 1이 되서 기본값으로 어떻게 돌아오지?
//
//
//switch countSwitchedStatus {
//case 0일때 :
//    countSWichButtonItem.image = UIImage(named: "timer0")
//
//case 3초일때 :
//    countSWichButtonItem.image = UIImage(named: "timer3")
//case 5초일때 :
//    countSWichButtonItem.image = UIImage(named: "timer5")
//case 10초일때 :
//    countSWichButtonItem.image = UIImage(named: "timer10")




//만약 timeLeft를 = 0으로 만들어 놓고 이걸 다시 변수 처리 하면? 되나?
// timeLeft = timeLeftOne 이런식으로 하는법?


/*
uilable을 만들어서 거기에 카운트 다운을 표시할거다. 아님 택스트 필드를 만들어도 되길 할듯
else if leftNumber < rightNumber {
    rightScore += 1
    rightScoreLabel.text = String(rightScore)

 위 코드를 응용하면된다.
 
 위 코드가 작동하는건, 액션 버튼을 만들거고 그걸 눌렀을때 카운트 다운이 역으로 작동하게 할거다.
 if 문을 이용해서, 3초 5초 10초 만들어야지. 여기에 uiimage업데이트도 같이 해주면 될듯 각 if문 안에다가.
 
 */
