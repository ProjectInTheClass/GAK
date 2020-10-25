//
//  ViewController.swift
//  gridetest2
//
//  Created by 서인재 on 2020/10/10.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnGrid(_ sender: UIButton) {
        UIGraphicsBeginImageContext(imageView.frame.size) //콘텍스트를 이미지 뷰의 크기와 같게 생성한다.
            let context = UIGraphicsGetCurrentContext()! // 생성한 콘텍스트의 정보를 가져온다.
        
        // 네모 그리기
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.gray.cgColor) // 선 색상
        context.setFillColor(UIColor.gray.cgColor) // 선 내부 색상
        
        let first = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        context.addRect(first)
        context.strokePath() // 추가한 경로를 콘텍스트에 그립니다.
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext() // 현재 콘텍스트에 그려진 이미지를 가지고 와서 이미지 뷰에 나타냅니다.
        UIGraphicsEndImageContext() // 그림 그리기를 끝낸다.
        
    }
}

