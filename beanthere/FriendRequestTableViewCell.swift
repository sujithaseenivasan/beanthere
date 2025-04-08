//
//  FriendRequestTableViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var friendRequestName: UILabel!
    
    @IBOutlet weak var friendRequestUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func confirmFriendRequest(_ sender: Any) {
    }
    
    
    @IBAction func deleteFriendRequest(_ sender: Any) {
    }
    
}
