//
//  ViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 2/27/25.
//

import UIKit

class ViewController: UIViewController {
    
    let segueIdentifier = "splashSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Go to login screen after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.performSegue(withIdentifier: self.segueIdentifier, sender: self)
        }
    }


}

