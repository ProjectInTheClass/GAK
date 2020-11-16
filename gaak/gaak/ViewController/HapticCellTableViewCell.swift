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
    
    @IBAction func rightSwitchToggle(_ sender: Any) {
        print("Haptic On/Off")
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
