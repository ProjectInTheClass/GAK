//
//  CameraViewControllerExtension.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/02.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewControllerExtension: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: ImageZoomViewController =
                segue.destination as? ImageZoomViewController else { return }
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else { return }
        
        //guard let index: IndexPath = self.(?) else { return }
        
        
        
    }
}
