//
//  TutorialContentsVC.swift
//  OnBoardScreenTed
//
//  Created by Ted Kim on 2020/11/12.
//

import Foundation
import UIKit

class TutorialContentsVC: UIViewController {
    
    var titleText: String!
    var imageFile: String!
    var pageIndex: Int!
    
    var titleLabel: UILabel!
    var bgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        titleLabel = UILabel()
        bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height))
        bgImageView.contentMode = .scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        titleLabel.text = titleText
        print(titleText!)
        
        guard let img = UIImage(named: imageFile) else {return}
        
        bgImageView.image = img
        
        view.addSubview(bgImageView)

        titleLabel.frame = CGRect(x: view.frame.width/2, y: view.frame.height-100, width: 100, height: 30)
        view.addSubview(titleLabel)
    }
}
