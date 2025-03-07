//
//  UserSettingVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/4/25.
//

import UIKit
import SwiftUICore
// tabView struct
//struct TabView<SelectionValue, Content> where Selection
//Value : Hashable, Content : View

class UserSettingVC: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //make image round
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        
        //Add code to the things that segue to remove back button and reallocate segue
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        
    }
}
