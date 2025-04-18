//
//  followingNavVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit

class followingNavVC: UIViewController {

    @IBOutlet weak var followingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

class followingCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
}
