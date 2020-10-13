//
//  ImageZoomViewController.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/06.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import Photos

class ImageZoomViewController: UIViewController {

    var asset: PHAsset!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // optional error is occured !
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                  contentMode: .aspectFill,
                                  options: nil, resultHandler: { image, _ in
                                    self.imageView.image = image
                                  }) // 에셋에서 image를 호출해달라!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
