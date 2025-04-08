//
//  FriendSuggestionCollectionViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit

class FriendSuggestionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var suggestedFriendImage: UIImageView!
    
    @IBOutlet weak var suggestedFriendName: UILabel!
    
    
    @IBOutlet weak var suggestedFriendUsername: UILabel!
    
    
    @IBOutlet weak var suggestedFriendFollowButton: UIButton!
    
    @IBAction func suggestedFriendFollowRequest(_ sender: Any) {
        suggestedFriendFollowButton.titleLabel?.text = "Requested"
    }
}
