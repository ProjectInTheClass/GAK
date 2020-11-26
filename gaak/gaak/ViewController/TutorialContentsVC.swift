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

        guard let img = UIImage(named: imageFile) else {
            print("Here is TutorialContentsVC: viewWillAppear")
            return
        }

        bgImageView.image = img

        view.addSubview(bgImageView)
    }
}
