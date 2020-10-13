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


class PhotoAlbumViewController: UIViewController, PHPhotoLibraryChangeObserver {
    
    
    @IBOutlet weak var pickPhotoImageBarButton: UIBarButtonItem!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var delegate: pickedImageSentDelegate? = nil
    var sizeOfImage:CGSize? // PrevieImageView의 CGSzie
    var assetsFetchResults: PHFetchResult<PHAsset>!
    var imageManger: PHCachingImageManager?
    var authorizationStatus: PHAuthorizationStatus?
    var currentSelectedIndex: Int? // Fetch Results의 인덱스, assets.
    
    // test lines
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    } // <- 사용자가 직접 편집할 수 있게 함
    
    // editing style을 설정하는 함수가 table view 함수에는 있는데 collection view 함수는 없음.. 혹시 에디팅을 추가하게 된다면 이 부분에 넣는게 좋을듯.
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: assetsFetchResults) else { return }
        
        assetsFetchResults = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.photoAlbumCollectionView.reloadSections(IndexSet(0...))
        }
    }
    
    
    // test lines end
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // delegate, datasource set
        //self.photoAlbumCollectionView.delegate = self
        //self.photoAlbumCollectionView.dataSource = self
        
        //Init value
        pickPhotoImageBarButton.isEnabled = false
        
        // Init Flow Layout !
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

// MARK: UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    // 몇 개를 보여줄지?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.assetsFetchResults?.count)!
    }
    
    // 셀은 어덯게 표현할지?
    // 재사용가능한 셀을 가져와서, 셀을 업데이트 -> 넘겨줌
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
    //셀이 터치됐을 때 어떻게 할지?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("--> \(indexPath.item)")
        performSegue(withIdentifier: "showDetail", sender: indexPath.item)
        // performSegue를 사용해서 넘기는건 내 방식
        
        // currentSelectedIndex = indexPath.item
        // currentSelectedIndex 이 변수는 나중에 선택, 삭제 기능구현할 때 사용할 수 있음.
        // pickPhotoImageBarButton.isEnabled = true
    }
    
    // MARK: - 데이터 넘기기
    // ImageZoomViewController 로 데이터를 넘기는 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: ImageZoomViewController = segue.destination as? ImageZoomViewController else { return }
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else { return }
        
        guard  let index: IndexPath = self.photoAlbumCollectionView.indexPath(for: cell) else { return }
        
        nextViewController.asset = self.assetsFetchResults[index.item]
        // ImageZoomViewController에 있는 asset으로 데이터를 넘겨줌.
    }

}
