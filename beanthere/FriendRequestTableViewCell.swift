//
//  FriendRequestTableViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/8/25.
//

import UIKit

protocol FriendRequestCellDelegate: AnyObject {
    func didTapConfirm(for friendId: String, cell: FriendRequestTableViewCell)
    func didTapDelete(for friendId: String, cell: FriendRequestTableViewCell)
}

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var friendRequestName: UILabel!
    
    @IBOutlet weak var friendRequestUsername: UILabel!
    
    var friendId: String?
    
    weak var delegate: FriendRequestCellDelegate?
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func confirmFriendRequest(_ sender: Any) {
        if let friendId = friendId {
            delegate?.didTapConfirm(for: friendId, cell: self)
        }
    }
    
    
    @IBAction func deleteFriendRequest(_ sender: Any) {
        if let friendId = friendId {
            delegate?.didTapDelete(for: friendId, cell: self)
        }
    }
    
}
