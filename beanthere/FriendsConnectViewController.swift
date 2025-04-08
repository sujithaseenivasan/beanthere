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
    
    
    @IBOutlet weak var testForFriendID: UILabel!
    
    var friendsList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewRequests",
           let nextVC = segue.destination as? FriendRequestsViewController {
            nextVC.delegate = self
        } else if segue.identifier == "suggGoToFriendProfID" || segue.identifier == "contactGoToFriendProfID" , let nextVC = segue.destination as? FriendProfileVC {
            nextVC.delegate = self
            nextVC.friendID = testForFriendID.text ?? ""
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    // function that when you select 1 cell of the friends user, segue into the friendsProfileVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the item that was tapped
        let selectedFriend = friendsList[indexPath.row]
        let friendVC = FriendProfileVC()
        // Pass the data
        friendVC.friendID = testForFriendID.text ?? ""
        //Push the friendsProfileVC
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
    
}
