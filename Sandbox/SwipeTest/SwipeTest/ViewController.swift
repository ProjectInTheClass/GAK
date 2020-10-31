//
//  ViewController.swift
//  SwipeTest
//
//  Created by 서인재 on 2020/10/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!
    
    
    //이미지를 보관할 배열 선언
    var imgLeft = [UIImage]()
    var imgRight = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 각 배열에 이미지 추가
        imgLeft.append(UIImage(named: "ArrowLeft1")!)
        imgLeft.append(UIImage(named: "ArrowLeft2")!)
        imgRight.append(UIImage(named: "ArrowRight1")!)
        imgRight.append(UIImage(named: "ArrowRight2")!)
        
        // 각 이미지 뷰에 초기 이미지(검은색 화살표) 저장
        imageViewLeft.image = imgLeft[0]
        imageViewRight.image = imgRight[0]
        
        
        //한 손가락 스와이프 제스처 등록
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
              swipeRight.direction = UISwipeGestureRecognizer.Direction.right
              self.view.addGestureRecognizer(swipeRight)
        
    }
    
     /// 실험중
    // 한 손가락 스와이프 제스쳐를 행했을 때 실행할 액션 메서드
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
           
            // 각각의 이미지 뷰에 초기 이미지(검은색 화살표) 저장
            imageViewLeft.image = imgLeft[0]
            imageViewRight.image = imgRight[0]
            
            // 발생한 이벤트가 각 방향의 스와이프 이벤트라면 해당 이미지 뷰를 빨간색 화살표 이미지로 변경
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    imageViewLeft.image = imgLeft[1]
                case UISwipeGestureRecognizer.Direction.right :
                    imageViewRight.image = imgRight[1]
                default:
                    break
            }
        }
    }
}

