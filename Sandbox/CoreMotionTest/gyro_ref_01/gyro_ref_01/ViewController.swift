//
//  ViewController.swift
//  gyro_ref_01
//
//  Created by Ted Kim on 2020/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var fireButton: UIImageView!
    @IBOutlet weak var angleBar: UISlider!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let current = Int(sender.value)
        textLabel.text = "\(current)"
        
        let temp = Double(current)
        var transform = CATransform3DIdentity;
        transform.m34 = 1.0/500
        transform = CATransform3DRotate(
            transform,
            CGFloat(temp * Double.pi / 180), 1, 0, 0
        )
        
        fireButton.layer.transform = transform
        
        if (temp < 5 && temp > -5) {
            fireButton.alpha = 1.0
            fireButton.tintColor = UIColor.red
        }
        else {
            fireButton.alpha = CGFloat(-abs(temp/90))+1.0
            fireButton.tintColor = UIColor.black
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        angleBar.minimumValue = -90
        angleBar.maximumValue = 90
        angleBar.value = -90
    }

    
    

}

