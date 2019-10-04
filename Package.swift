// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "INSPhotoGallery",    
    platforms: [
      .iOS(.v8)
    ],
    products: [        
        .library(name: "INSPhotoGallery", targets: ["INSPhotoGallery"]),
    ],
    targets: [     
        .target(name: "INSPhotoGallery", path: "INSPhotoGallery"),
    ]
)
