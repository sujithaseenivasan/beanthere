//
//  FriendContactsCollectionViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FriendContactsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contactFriendImage: UIImageView!
    
    
    @IBOutlet weak var contactFriendName: UILabel!
    
    
    @IBOutlet weak var contactFriendUsername: UILabel!
    
    
    @IBOutlet weak var contactFriendFollowButton: UIButton!
    
    var friendId: String?
    
    @IBAction func contactFriendFollowRequest(_ sender: Any) {
        guard let friendId = friendId, let currUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        // update the current user's "requested" field
        db.collection("users").document(currUserId).updateData([
            "requested": FieldValue.arrayUnion([friendId])
        ]) { error in
            if let error = error {
                print("Error updating current user's requested list: \(error)")
            } else {
                print("Current user's requested list updated")
                // update the friend's "requests" list
                db.collection("users").document(friendId).updateData([
                    "requests": FieldValue.arrayUnion([currUserId])
                ]) { error in
                    if let error = error {
                        print("Error updating target friend's requests list: \(error)")
                    } else {
                        print("Target friend's requests list updated")
                        // update the button's title to requested
                        DispatchQueue.main.async {
                            self.contactFriendFollowButton.titleLabel?.text = "Sent"
                            self.contactFriendFollowButton.titleLabel?.textAlignment = .center
                        }
                    }
                }
            }
        }
    }
    
}
