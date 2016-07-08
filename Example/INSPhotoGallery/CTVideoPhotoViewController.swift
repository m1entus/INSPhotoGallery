//
//  CTVideoPhotoViewController.swift
//  INSPhotoGallery
//
//  Created by WOO Yu Kit on 5/7/2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGalleryFramework

class CTVideoPhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var photos: [CTGalleryPhoto] = {
        return [
            CTGalleryPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CTGalleryPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CTGalleryPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "thumbnailImage")!),
            CTGalleryPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
            CTGalleryPhoto(videoURL: NSURL(string: "https://a0.muscache.com/airbnb/static/belo-3.mp4"), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
            CTGalleryPhoto(videoURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("splash", ofType: "mp4")!), thumbnailImageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"))
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension CTVideoPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExampleCollectionViewCell", forIndexPath: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[indexPath.row])
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[indexPath.row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        let overylayView = CTGalleryOverlayView(frame: CGRect.zero)
        galleryPreview.overlayView = overylayView
        
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
