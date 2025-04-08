//
//  FriendRequestsViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit

//class FriendRequestTableViewCell: UITableViewCell {
//    
//    
//}

let friendRequestCellIdentifier = "FriendRequestCell"

class FriendRequestsViewController: UIViewController {

    @IBOutlet weak var friendRequestsTable: UITableView!
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
