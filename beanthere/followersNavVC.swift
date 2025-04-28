//
//  followersNavVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Friends {
    var id: String?
    var name: String?
    var username: String?
    var picture: UIImage?
}
class followersNavVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowersCellDelegate {
    
    @IBOutlet weak var followersTableView: UITableView!
    var navUserId: String?
    var delegate: UIViewController!
    var followersList:[Friends] = []
    var isUserProfile: Bool = false
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followersTableView.delegate = self
        followersTableView.dataSource = self
        populateFollowingOrFollowersList(userID: navUserId!, followers: true){ followersList in
            if followersList.count > 0{
                self.followersList = followersList
                DispatchQueue.main.async {
                    self.followersTableView.reloadData()
                }
            }
        }
        followersTableView.rowHeight = 100
    }
    
    //protocol function that handles when delete is called. It deletes your follower and goes and deletes you from your friends followings
    func didTapDelete(for friendId: String, cell: followersCell) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userDocRef = db.collection("users").document(currentUserId)
        userDocRef.updateData([
            "followers": FieldValue.arrayRemove([friendId])
        ]) { error in
            if let error = error {
                print("Error updating current user follower: \(error)")
            } else {
                let friendDocRef = self.db.collection("users").document(friendId)
                friendDocRef.updateData([
                    "friendsList": FieldValue.arrayRemove([currentUserId])
                ]) { error in
                    if let error = error {
                        print("Error updating friend's followings list: \(error)")
                    } else {
                        print("Follower removed successfully.")
                        if let index = self.followersList.firstIndex(where: { $0.id == friendId }) {
                            self.followersList.remove(at: index)
                            DispatchQueue.main.async {
                                self.followersTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userFollower = self.followersList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCellID", for: indexPath) as! followersCell
        
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



class followersCell: UITableViewCell{
    var delegate: FollowersCellDelegate?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var friendID: String?
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let friendId = friendID {
            delegate?.didTapDelete(for: friendId, cell: self)
        }
    }
    
}
