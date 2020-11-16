//
//  HapticCellTableViewCell.swift
//  gaak
//
//  Created by 서인재 on 2020/11/16.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit

class HapticCellTableViewCell: UITableViewCell {

    
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet weak var rightSwitch: UISwitch!
    
    @IBAction func rightSwitchToggle(_ sender: UISwitch) {
       //어떻게 햅틱 기능을 활용하는지 모르겠네요 ㅜ
        if sender.isOn{
//            isImpactH = true
//            isImpactV = true
//            isImpactY = true
//            isSkyShot = true
            print("Haptic switch is on!")
        } else {
//            isImpactH = false
//            isImpactV = false
//            isImpactY = false
//            isSkyShot = false
            print("Haptic switch is off")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
