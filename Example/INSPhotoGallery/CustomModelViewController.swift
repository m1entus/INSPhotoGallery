//
//  CustomModelViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGallery
import Photos


class CustomModelViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var photos: [CustomPhotoModel] = {
        return [
            CustomPhotoModel(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
            CustomPhotoModel(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
            CustomPhotoModel(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"))
        ]
    }()
    private var assets: [PHAsset]! {
        willSet {
            PHCachingImageManager().stopCachingImagesForAllAssets()
        }
        
        didSet {
            PHCachingImageManager().startCachingImagesForAssets(self.assets, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.AspectFill, options: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension CustomModelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExampleCollectionViewCell", forIndexPath: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[indexPath.row])
        cell.dataSource = self
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[indexPath.row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        galleryPreview.overlayView = CustomOverlayView(frame: CGRect.zero)
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.indexOf({$0 === photo}) {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ExampleCollectionViewCell
                return cell
            }
            return nil
        }
        presentViewController(galleryPreview, animated: true, completion: nil)
    }
}

extension CustomModelViewController: SelectCollectionViewCellDataSource {
    func getSelectIndex() -> String {
        return "1"
    }
}
