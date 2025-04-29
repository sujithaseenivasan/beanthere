//
//  followingNavVC.swift
//  beanthere
// This is where you can see all the people you are following and so that you can delete some of them if you want to unfollow them
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class followingNavVC: UIViewController,  UITableViewDelegate, UITableViewDataSource, FollowingCellDelegate {

    @IBOutlet weak var followingTableView: UITableView!
    var navUserId: String!
    var delegate: UIViewController!
    var followingList:[Friends] = []
    var isUserProfile: Bool = false
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followingTableView.delegate = self
        followingTableView.dataSource = self
        populateFollowingOrFollowersList(userID: navUserId!, followers: false){ followingList in
            if followingList.count > 0{
                self.followingList = followingList
                DispatchQueue.main.async {
                    self.followingTableView.reloadData()
                }
            }
        }
        followingTableView.rowHeight = 100
    }
    
    // this is one of the protocol functions that if you delete the row of followings it will delete them from your firebase and your friends followers list
    func didTapDelete(for friendId: String, cell: followingCell) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userDocRef = db.collection("users").document(currentUserId)
        userDocRef.updateData([
            "friendsList": FieldValue.arrayRemove([friendId])
        ]) { error in
            if let error = error {
                print("Error updating current user followings list: \(error)")
            } else {
                let friendDocRef = self.db.collection("users").document(friendId)
                friendDocRef.updateData([
                    "followers": FieldValue.arrayRemove([currentUserId])
                ]) { error in
                    if let error = error {
                        print("Error updating friend's follower list: \(error)")
                    } else {
                        print("Following removed  successfully.")
                        if let index = self.followingList.firstIndex(where: { $0.id == friendId }) {
                            self.followingList.remove(at: index)
                            DispatchQueue.main.async {
                                self.followingTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userFollower = self.followingList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCellID", for: indexPath) as! followingCell
        
        cell.delegate = self
        cell.name.text = userFollower.name
        cell.userName.text = userFollower.username
        cell.userImage.image = userFollower.picture
        cell.friendID = userFollower.id
        makeImageOval(cell.userImage)
        //hide the delete button if it is not the user that segued there
        cell.deleteButton.isHidden = !isUserProfile
        return cell
        
        
    }
}


class followingCell: UITableViewCell{
    var delegate: FollowingCellDelegate?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    var friendID: String?
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let friendId = friendID {
            delegate?.didTapDelete(for: friendId, cell: self)
        }
    }
    
    
}
