//
//  FriendsConnectViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit

class FriendsConnectViewController: UIViewController {
    
    
//    @IBOutlet weak var suggestFriendsCollection: UICollectionView!
//    
//    @IBOutlet weak var contactsFriendsCollection: UICollectionView!
//    
//    @IBOutlet weak var suggestedFriendImage: UIImageView!
//    
//    
//    @IBOutlet weak var suggestedFriendName: UILabel!
//    
//    @IBOutlet weak var suggestedFriendUsername: UILabel!
//    
//    
//    @IBOutlet weak var contactsFriendImage: UIImageView!
//    
//    
//    @IBOutlet weak var contactsFriendName: UILabel!
//    
//    
//    @IBOutlet weak var contactsFriendUsername: UILabel!
//
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewRequests",
           let nextVC = segue.destination as? FriendRequestsViewController {
            nextVC.delegate = self
        }
    }
    
    
    @IBAction func followSuggestedFriend(_ sender: Any) {
    }
    
    
    @IBAction func followContactsFriend(_ sender: Any) {
    }
    
}
