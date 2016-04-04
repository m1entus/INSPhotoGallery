//
//  ViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var useCustomOverlay = false
    
    lazy var photos: [INSPhoto] = {
        return [
            INSPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            INSPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "thumbnailImage")!)
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        let galleryPreview = INSPhotosViewController<INSPhoto>(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            galleryPreview.overlayView = CustomOverlayView(frame: CGRect.zero)
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.indexOf(photo) {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ExampleCollectionViewCell
                return cell
            }
            return nil
        }
        presentViewController(galleryPreview, animated: true, completion: nil)
    }
}