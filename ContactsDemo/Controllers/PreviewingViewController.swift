//
//  PreviewingViewController.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 17/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit

class PreviewingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image_ = image {
            self.imageView.image = image_

        }
    }

}
