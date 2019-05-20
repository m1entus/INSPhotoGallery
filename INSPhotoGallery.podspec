Pod::Spec.new do |s|
  s.name     = 'INSPhotoGallery'
  s.version  = '1.3.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'INSPhotoGallery is a modern looking photo gallery written in Swift for iOS.'
  s.homepage = 'https://github.com/chrigu1981/INSPhotoGallery'
  s.authors  = 'Michał Zaborowski'
  s.source   = { :git => 'https://github.com/chrigu1981/INSPhotoGallery.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.ios.resource_bundle = { s.name => ['INSPhotoGallery/INSPhotoGallery.bundle/*'] }
  s.source_files = 'INSPhotoGallery/**/*.{h,m,swift}'

  s.platform = :ios, '8.0'
  s.frameworks = 'UIKit', 'Foundation'
end
