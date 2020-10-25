//
//  ViewController.swift
//  CGpratice
//
//  Created by 서인재 on 2020/10/09.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnDrawSmile(_ sender: UIButton) {
        UIGraphicsBeginImageContext(imgView.frame.size) // 콘텍스트를 이미지 뷰의 크기와 같게 생성합니다.
        let context = UIGraphicsGetCurrentContext()! // 생성한 콘텍스트의 정보를 가져옵니다.
        
        //눈 그리기(원 2개)
        context.setLineWidth(2.0) // 선 굵기
        context.setStrokeColor(UIColor.black.cgColor) // 선 색상 설정
        context.setFillColor(UIColor.black.cgColor) // 도형 내부를 색상으로 설정
        
        let circleEye1 = CGRect(x: 30, y: 100, width: 100, height: 100) // 시작 위치를(70, 50)으로 설정하고, 너비를 100px, 높이 100px인 원을 그립니다.
        let circleEye2 = CGRect(x: 210, y: 100, width: 100, height: 100) // 시작 위치를 (210, 100)으로 설정하고, 너비 100px, 높이 100px인 원을 그립니다.
        context.addEllipse(in: circleEye1)
        context.fillEllipse(in: circleEye1) // 원의 내부를 색상으로 채웁니다.
        context.addEllipse(in: circleEye2)
        context.fillEllipse(in: circleEye2)
        context.strokePath() // 추가한 경로를 컨텍스트에 그립니다.
        
        //입 그리기(세모 1개)
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.red.cgColor)
        
        context.move(to: CGPoint(x: 170, y: 400))
        context.addLine(to: CGPoint(x: 240, y: 350))
        context.addLine(to: CGPoint(x: 100, y: 350))
        context.addLine(to: CGPoint(x: 170, y: 400))
        context.fillPath() // 선의 내부를 색상으로 채웁니다.
        context.strokePath()
        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext() // 현재 콘텍스트에 그려진 이미지를 가지고 와서 이미지 뷰에 나타냅니다.
        UIGraphicsEndImageContext() // 그림 그리기를 끝냅니다.
        
        
        
    }
    //표정2 화남
    @IBAction func btnDrawUpset(_ sender: UIButton) {
        
        UIGraphicsBeginImageContext(imgView.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        
        //눈 그리기(네모 2개)
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setFillColor(UIColor.black.cgColor)
        
        let rectEye1 = CGRect(x: 30, y: 100, width: 100, height: 20)
        let rectEye2 = CGRect(x: 210, y: 100, width: 100, height: 20)
        
        context.addRect(rectEye1)
        context.fill(rectEye1)
        context.addRect(rectEye2)
        context.fill(rectEye2)
        context.strokePath() // 추가한 경로를 콘텍스트에 그립니다.
        
        // 입 그리기(호 2개)
        context.setLineWidth(10.0)
        context.setStrokeColor(UIColor.blue.cgColor)
        
        context.move(to: CGPoint(x: 100, y: 350))
        context.addArc(tangent1End: CGPoint(x: 100, y: 250), tangent2End: CGPoint(x: 240, y: 250), radius: CGFloat(70))
        
        context.move(to: CGPoint(x: 240, y: 350))
        context.addArc(tangent1End: CGPoint(x: 240, y: 250), tangent2End: CGPoint(x: 100, y: 250), radius: CGFloat(70))
        
        context.strokePath()

        
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
}

