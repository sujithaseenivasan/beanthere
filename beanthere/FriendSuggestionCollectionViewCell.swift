//
//  FriendSuggestionCollectionViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendSuggestionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var suggestedFriendImage: UIImageView!
    
    @IBOutlet weak var suggestedFriendName: UILabel!
    
    @IBOutlet weak var suggestedFriendUsername: UILabel!
    
    @IBOutlet weak var suggestedFriendFollowButton: UIButton!
    
    var friendId: String?
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        suggestedFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        suggestedFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
//    }
    
    @IBAction func suggestedFriendFollowRequest(_ sender: Any) {
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
                            self.suggestedFriendFollowButton.titleLabel?.text = "Sent"
                            self.suggestedFriendFollowButton.titleLabel?.textAlignment = .center
                            self.suggestedFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
                        }
                    }
                }
            }
        }
    }
}
