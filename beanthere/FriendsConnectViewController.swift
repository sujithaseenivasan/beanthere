//
//  FriendsConnectViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit

let suggestFriendCellIdentifier = "SuggestedFriendCell"
let contactsFriendCellIdentifier = "ContactsFriendCell"

class FriendsConnectViewController: UIViewController {
    
    
    @IBOutlet weak var suggestFriendsCollection: UICollectionView!
    
    @IBOutlet weak var contactsFriendsCollection: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewRequests",
           let nextVC = segue.destination as? FriendRequestsViewController {
            nextVC.delegate = self
        }
    }
    
}
