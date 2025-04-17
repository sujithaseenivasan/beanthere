//
//  FriendRequestsViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct FriendRequest {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
}

let friendRequestCellIdentifier = "FriendRequestCell"

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate {

    @IBOutlet weak var friendRequestsHeaderLabel: UILabel!
    
    @IBOutlet weak var friendRequestsTable: UITableView!
    
    var delegate: UIViewController!
    
    var requests: [FriendRequest] = []
    
    var currentUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendRequestsTable.delegate = self
        friendRequestsTable.dataSource = self
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user found.")
            return
        }
        self.currentUserId = userId
        
        loadFriendRequests()
    }
    
    func loadFriendRequests() {
        guard let currentUserId = self.currentUserId else { return }
        let db = Firestore.firestore()
        
        // get the current user's document to access the "requests" field
        db.collection("users").document(currentUserId).getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                return
            }
            
            if let requestsArray = data["requests"] as? [String] {
                // fetch details for each friend request
                var loadedRequests: [FriendRequest] = []
                let group = DispatchGroup()
                
                for friendId in requestsArray {
                    group.enter()
                    db.collection("users").document(friendId).getDocument { (friendDoc, error) in
                        if let friendDoc = friendDoc,
                           friendDoc.exists,
                           let friendData = friendDoc.data() {
                            
                            let firstName = friendData["firstName"] as? String ?? ""
                            let lastName = friendData["lastName"] as? String ?? ""
                            var username = friendData["username"] as? String ?? ""
                            
                            // use first+last name if username is empty
                            if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                username = firstName + lastName
                            }
                            
                            let friend = FriendRequest(id: friendId, firstName: firstName, lastName: lastName, username: username)
                            loadedRequests.append(friend)
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.requests = loadedRequests
                    self.friendRequestsTable.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: friendRequestCellIdentifier, for: indexPath) as! FriendRequestTableViewCell
        
        let friend = requests[indexPath.row]
        cell.friendRequestName.text = "\(friend.firstName) \(friend.lastName)"
        cell.friendRequestUsername.text = friend.username
        cell.friendId = friend.id
        cell.delegate = self
        
        return cell
    }
    
    func didTapConfirm(for friendId: String, cell: FriendRequestTableViewCell) {
        guard let currentUserId = self.currentUserId else { return }
        let db = Firestore.firestore()
        
        let userDocRef = db.collection("users").document(currentUserId)
        userDocRef.updateData([
            "requests": FieldValue.arrayRemove([friendId]),
            "followers": FieldValue.arrayUnion([friendId])
        ]) { error in
            if let error = error {
                print("Error updating current user document: \(error)")
            } else {
                let friendDocRef = db.collection("users").document(friendId)
                friendDocRef.updateData([
                    "requested": FieldValue.arrayRemove([currentUserId])
                ]) { error in
                    if let error = error {
                        print("Error updating friend document: \(error)")
                    } else {
                        print("Friend request confirmed successfully.")
                        // remove the friend and update the table view
                        if let index = self.requests.firstIndex(where: { $0.id == friendId }) {
                            self.requests.remove(at: index)
                            DispatchQueue.main.async {
                                self.friendRequestsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func didTapDelete(for friendId: String, cell: FriendRequestTableViewCell) {
        guard let currentUserId = self.currentUserId else { return }
        let db = Firestore.firestore()
        
        let userDocRef = db.collection("users").document(currentUserId)
        userDocRef.updateData([
            "requests": FieldValue.arrayRemove([friendId])
        ]) { error in
            if let error = error {
                print("Error updating current user requests: \(error)")
            } else {
                let friendDocRef = db.collection("users").document(friendId)
                friendDocRef.updateData([
                    "requested": FieldValue.arrayRemove([currentUserId])
                ]) { error in
                    if let error = error {
                        print("Error updating friend's requested list: \(error)")
                    } else {
                        print("Friend request declined successfully.")
                        if let index = self.requests.firstIndex(where: { $0.id == friendId }) {
                            self.requests.remove(at: index)
                            DispatchQueue.main.async {
                                self.friendRequestsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        }
                    }
                }
            }
        }
    }
}
