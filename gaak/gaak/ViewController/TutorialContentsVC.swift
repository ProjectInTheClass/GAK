//
//  TutorialContentsVC.swift
//  gaak
//
//  Created by 서인재 on 2020/11/15.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit

class TutorialContentsVC: UIViewController {
    
    var imageFile: String!
    var pageIndex: Int!
    
    var bgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height))
        bgImageView.contentMode = .scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //titleLabel.text = titleText
        //print(titleText!)

        guard let img = UIImage(named: imageFile) else {return}

        bgImageView.image = img

        view.addSubview(bgImageView)

        // 현재는 필요 없는 코드, 각 페이지의 이름을 정해줄 수 있다.
        //titleLabel.frame = CGRect(x: view.frame.width/2, y: view.frame.height-100, width: 100, height: 30)
        //view.addSubview(titleLabel)
    }
}
