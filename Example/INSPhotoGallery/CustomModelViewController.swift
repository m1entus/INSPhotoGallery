//
//  CustomModelViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGalleryFramework

class CustomModelViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var photos: [CustomPhotoModel] = {
        return [
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "thumbnailImage")!),
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg") ),
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg") ),
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"))
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension CustomModelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)

        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
                return cell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
}
