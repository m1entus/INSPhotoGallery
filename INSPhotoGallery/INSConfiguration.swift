//
//  INSConfiguration.swift
//  INSPhotoGallery
//
//  Created by Danil Blinov on 25.06.2020.
//  Copyright © 2020 Inspace. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this library except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit

public class INSConfiguration: NSObject {
    /*
    * Specify backgroundColor for INSScalingImageView
    */
    open var backgroundColor: UIColor = .black

	  /*
	  * Specify backgroundColor for INSScalingImageView .imageView
	  */
	  open var imageViewBackgroundColor: UIColor = .clear
    /*
	
    * Specify color for UIActivityIndicatorView
    */
    open var activityIndicatorColor: UIColor = .white
    
    /*
    * Specify color for UIActivityIndicatorView
    */
    open var navigationTitleTextColor: UIColor = .white
    
    /*
    * Specify parameters for INSPhotosOverlayViewable
    */
    open var shadowStartColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    open var shadowEndColor: UIColor = UIColor.clear
    open var shadowHidden: Bool = false
    
    open var rightBarButtonHidden: Bool = false
    open var leftBarButtonHidden: Bool = false

}
