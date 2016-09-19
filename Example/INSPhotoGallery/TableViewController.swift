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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier , identifier == "customOverlay" {
            if let destinationVC = segue.destination as? ViewController {
                destinationVC.useCustomOverlay = true
            }
        }
    }
}
