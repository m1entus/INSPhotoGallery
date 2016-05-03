[![](http://inspace.io/github-cover.jpg)](http://inspace.io)

# Introduction

**INSPhotoGallery** was written by **[Michał Zaborowski](https://github.com/m1entus)** for **[inspace.io](http://inspace.io)**

# INSPhotoGallery

`INSPhotoGallery` is a modern looking photo gallery written in `Swift` for iOS. `INSPhotoGallery` can handle downloading of photos but in addition to that it allows you to make custom logic for downloading images, also it allows you to make custom overlay if you won't like current design. In addition it support interactive flick to dismiss, animated zooming presentation and many more. It was inspired by [NYTPhotoViewer](https://github.com/NYTimes/NYTPhotoViewer).

[![](https://raw.github.com/inspace-io/INSPhotoGallery/master/Screens/animation.gif)](https://raw.github.com/inspace-io/INSPhotoGallery/master/Screens/animation.gif)
[![](https://raw.github.com/inspace-io/INSPhotoGallery/master/Screens/screen.png)](https://raw.github.com/inspace-io/INSPhotoGallery/master/Screens/screen.png)

# Simple Usage

```swift
lazy var photos: [INSPhotoViewable] = {
    return [
        INSPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
        INSPhoto(imageURL: NSURL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!),
        INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "thumbnailImage")!),
    ]
}()
```

```swift
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ExampleCollectionViewCell
    let currentPhoto = photos[indexPath.row]
    let galleryPreview = INSPhotosViewController<INSPhoto>(photos: photos, initialPhoto: currentPhoto, referenceView: cell)

    galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
        if let index = self?.photos.indexOf({$0 === photo}) {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            return collectionView.cellForItemAtIndexPath(indexPath) as? ExampleCollectionViewCell
        }
        return nil
    }
    presentViewController(galleryPreview, animated: true, completion: nil)
}
```

# Custom Photo Model

You are able to create your custom photo model which can be use instead default `INSPhoto`. Default implementation don't cache images. If you would like to use some caching mechanism or use some library for downloading images for example `HanekeSwift` use must implement `INSPhotoViewable` protocol.

```swift
@objc public protocol INSPhotoViewable: class {
    var image: UIImage? { get }
    var thumbnailImage: UIImage? { get }

    func loadImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ())
    func loadThumbnailImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ())

    var attributedTitle: NSAttributedString? { get }
}
```

```swift
class CustomPhotoModel: NSObject, INSPhotoViewable {
  var image: UIImage?
  var thumbnailImage: UIImage?

  var imageURL: NSURL?
  var thumbnailImageURL: NSURL?

  func loadImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ()) {
        if let url = imageURL {
            Shared.imageCache.fetch(URL: url).onSuccess({ image in
                completion(image: image, error: nil)
            }).onFailure({ error in
                completion(image: nil, error: error)
            })
        } else {
            completion(image: nil, error: NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
}
```

## CocoaPods

Add the following to your `Podfile` and run `$ pod install`.

``` ruby
pod 'INSPhotoGallery'
```

If you don't have CocoaPods installed, you can learn how to do so [here](http://cocoapods.org).

## Contact

[inspace.io](http://inspace.io)

[Twitter](https://twitter.com/inspace_io)

# License
```
Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this library except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.```
