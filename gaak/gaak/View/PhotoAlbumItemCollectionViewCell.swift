//
//  PhotoAlbumItemCollectionViewCell.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/06.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit

class PhotoAlbumItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isSelected {
            self.photoImageView.layer.borderColor = CGColor(red: 5, green: 197, blue: 144, alpha: 1)
            self.photoImageView.layer.borderWidth = 1
        } else {
            self.photoImageView.layer.borderColor = UIColor.clear.cgColor
            self.photoImageView.layer.borderWidth = 0
        }
}
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                self.photoImageView.layer.borderColor = CGColor(red: 5, green: 197, blue: 144, alpha: 1)
                self.photoImageView.layer.borderWidth = 1
            } else {
                self.photoImageView.layer.borderColor = UIColor.clear.cgColor
                self.photoImageView.layer.borderWidth = 0
            }
        }
    }
}
