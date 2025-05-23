//
//  MainProfileTableViewCell.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/8/25.
//

import UIKit

// create a class of a table cell and design it how you want it to look
class MainProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var drinkImg: UIImageView!
    @IBOutlet weak var cafeName: UILabel!
    @IBOutlet weak var cafeAdrr: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var bean2: UIImageView!
    @IBOutlet weak var bean3: UIImageView!
    @IBOutlet weak var bean4: UIImageView!
    @IBOutlet weak var bean5: UIImageView!
    @IBOutlet weak var bean11: UIImageView!
    @IBOutlet weak var friendsComment: UIImageView!
    @IBOutlet weak var share: UIImageView!
    @IBOutlet weak var youRanked: UILabel!
    @IBOutlet weak var rankDummy: UILabel!
    @IBOutlet weak var commentDummy: UILabel!
    var likeCount: Int = 0
    var reviewID: String = ""
    weak var delegate: MainProfileTableViewCellDel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeFonts()
        //put the tap gestures in the cell programmatically
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapRecognizer))
        likeImg.isUserInteractionEnabled = true
        likeImg.addGestureRecognizer(likeTap)
        
    }

    // functions to change for fonts
    func changeFonts(){
        youRanked.font = UIFont(name: "Lora-SemiBold", size: 14)
        rankDummy.font = UIFont(name: "Lora-Regular", size: 14)
        cafeName.font = UIFont(name: "Lora-Bold", size: 14)
        cafeAdrr.font = UIFont(name: "Lora-Regular", size: 14)
        commentDummy.font = UIFont(name: "Lora-Regular", size: 14)
        userComment.font = UIFont(name: "Lora-Regular", size: 14)
        rankDummy.font = UIFont(name: "Lora-Regular", size: 14)
        numLikes.font = UIFont(name: "Lora-Regular", size: 14)
    }
    
    //When tapped figure out if there likeImg if it is red if it is add numLiked, and save it in firestore
    @objc func likeTapRecognizer() {
        if likeImg.image == UIImage(systemName: "heart") {
            likeImg.image = UIImage(systemName: "heart.fill")
            likeImg.tintColor = .brown
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
        delegate?.didTapCommentButton(reviewID: reviewID)
    }
    
    
    
}

