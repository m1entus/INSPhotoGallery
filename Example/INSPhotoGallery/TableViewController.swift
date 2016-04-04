//
//  TableViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier where identifier == "customOverlay" {
            if let destinationVC = segue.destinationViewController as? ViewController {
                destinationVC.useCustomOverlay = true
            }
        }
    }
}
