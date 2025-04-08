//
//  FriendContactsCollectionViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit

class FriendContactsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contactFriendImage: UIImageView!
    
    
    @IBOutlet weak var contactFriendName: UILabel!
    
    
    @IBOutlet weak var contactFriendUsername: UILabel!
    
    
    @IBOutlet weak var contactFriendFollowButton: UIButton!
    
    
    @IBAction func contactFriendFollowRequest(_ sender: Any) {
        contactFriendFollowButton.titleLabel?.text = "Requested"
    }
    
}
