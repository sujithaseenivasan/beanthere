//
//  FriendSearchTableViewCell.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/9/25.
//

import UIKit

class FriendSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendSearchName: UILabel!
    

    @IBOutlet weak var friendSearchUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
