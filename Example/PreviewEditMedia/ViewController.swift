//
//  ViewController.swift
//  PreviewEditMedia
//
//  Created by huy-luvapay on 04/22/2021.
//  Copyright (c) 2021 huy-luvapay. All rights reserved.
//

import UIKit
import PreviewEditMedia

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentEditPhoto() {
        self.presetPhotoEditorViewController(photo: UIImage(named: "photo2.jpg")!)
    }
    
    
    @IBAction func showPressed() {
        self.presentEditPhoto()

    }
    

}
