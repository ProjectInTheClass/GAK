//
//  PhotoAlbumViewController.swift
//  gaak
//
//  Created by Ted Kim on 2020/10/06.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import Photos

protocol pickedImageSentDelegate {
    func setPickedImageFromPhotoAlbum(pickedImage: UIImage?, photoMode: AddPhotoMode)
}

private let reuseIdentifier = "ImageCell"


class PhotoAlbumViewController: UIViewController {
        
    @IBOutlet weak var pickPhotoImageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var delegate: pickedImageSentDelegate? = nil
    var sizeOfImage:CGSize? // PrevieImageView의 CGSzie
    var assetsFetchResults: PHFetchResult<PHAsset>?
    var imageManger: PHCachingImageManager?
    var authorizationStatus: PHAuthorizationStatus?
    var currentSelectedIndex: Int? // Fetch Results의 인덱스, assets.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // delegate, datasource set
        self.photoAlbumCollectionView.delegate = self
        self.photoAlbumCollectionView.dataSource = self
        
        //Init value
        pickPhotoImageBarButton.isEnabled = false
        
        setFlowLayout()
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                self.imageManger = PHCachingImageManager()
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                
                self.photoAlbumCollectionView?.reloadData()
           
            case .denied:
                print(authorizationStatusOfPhoto)
            case .notDetermined:
                print(authorizationStatusOfPhoto)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print(authorizationStatusOfPhoto)
            case .limited:
                print("접근제한(.limited): \(authorizationStatusOfPhoto)")
            @unknown default:
                print("@unknown error: \(authorizationStatusOfPhoto)")
            }
        }
    }
    
    func setFlowLayout() {
        let space:CGFloat = 3.0
        
        // the size of the main view, wihich is dependent upon screen size.
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        // 행 또는 열 내의 Item 사이의 공간을 제어합니다.
        collectionViewFlowLayout.minimumInteritemSpacing = space
        // 행 또는 열 사이의 공간을 제어합니다.
        collectionViewFlowLayout.minimumLineSpacing = space
        // cell(item) 사이즈를 제어합니다.
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK:- View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    @IBAction func canclePickImageFromPhotoAlbum(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/

// MARK: UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.assetsFetchResults?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumItemCollectionViewCell
        
        // cell frame CGSize만큼 asset을 설정하여 photoImageView에 setting
        let asset: PHAsset = self.assetsFetchResults![indexPath.item]
        self.imageManger?.requestImage(for: asset,
                                       targetSize: cell.frame.size,
                                       contentMode: PHImageContentMode.aspectFit,
                                       options: nil,
                                       resultHandler: { (result : UIImage?, info) in cell.photoImageView.image = result
                                       })
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentSelectedIndex = indexPath.item
        pickPhotoImageBarButton.isEnabled = true
    }
}
