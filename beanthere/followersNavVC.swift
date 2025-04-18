//
//  followersNavVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit

class followersNavVC: UIViewController {
    
    @IBOutlet weak var followersTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

class followersCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
}
