//
//  FriendProfileTVCell.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/8/25.
//
import UIKit
class FriendProfileTVCell: UITableViewCell {
    @IBOutlet weak var drinkImg: UIImageView!
    @IBOutlet weak var cafeName: UILabel!
    @IBOutlet weak var cafeAdrr: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var bean1: UIImageView!
    @IBOutlet weak var bean2: UIImageView!
    @IBOutlet weak var bean3: UIImageView!
    @IBOutlet weak var bean4: UIImageView!
    @IBOutlet weak var bean5: UIImageView!
    
    @IBOutlet weak var numLikes: UILabel!
    
    
    @IBOutlet weak var friendsComment: UIImageView!
    @IBOutlet weak var share: UIImageView!
    
    weak var delegate: FriendProfileTableViewCellDel?
    var likeCount: Int = 0
    var reviewID: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        //put the tap gestures in the cell programmatically
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapRecognizer))
        likeImg.isUserInteractionEnabled = true
        likeImg.addGestureRecognizer(likeTap)
        
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareTapRecognizer))
        share.isUserInteractionEnabled = true
        share.addGestureRecognizer(shareTap)
        
    }

    
    //When tapped figure out if there likeImg if it is red if it is add numLiked, and save it in firestore
    @objc func likeTapRecognizer() {
        if likeImg.image == UIImage(systemName: "heart") {
            likeImg.image = UIImage(systemName: "heart.fill")
            likeImg.tintColor = .red
            likeCount += 1
            populateReviewLikes (reviewID: reviewID, likeNum : likeCount)
        } else {
            likeImg.image = UIImage(systemName: "heart")
            likeImg.tintColor = .brown
            likeCount -= 1
            populateReviewLikes (reviewID: reviewID, likeNum : likeCount)
        }
        
       numLikes.text = "\(likeCount) likes"
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        print ("ENTERED COMMENT BUTTON IN CELL ")
        delegate?.didTapCommentButton(reviewID: reviewID)
    }
    
    
    @objc func commentTapRecognizer() {
    }
    
    @objc func shareTapRecognizer() {
    }
    
}

