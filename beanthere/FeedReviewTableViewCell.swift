//
//  FeedReviewTableViewCell.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/7/25.
//

import UIKit

class FeedReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var titleText: UILabel!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet var reviewTagLabels: [UILabel]!
    
    @IBOutlet weak var imageOne: UIImageView!
    
    @IBOutlet weak var imageTwo: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet var cafeBeanImageViews: [UIImageView]!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: FeedReviewCellDelegate?
        var reviewId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleText.font = UIFont(name: "Lora-Bold", size: 20)
        notesLabel.font = UIFont(name: "Lora-SemiBold", size: 14)
        locationLabel.font = UIFont(name: "Lora-SemiBold", size: 15)
        dateLabel.font = UIFont(name: "Lora-SemiBold", size: 15)
        likeCountLabel.font = UIFont(name: "Lora-SemiBold", size: 15)
        
        reviewTagLabels.forEach {
            $0.font = UIFont(name: "Lora-SemiBold", size: 10)
        }
    }


    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        guard let reviewId = reviewId else { return }
        delegate?.didTapLikeButton(for: reviewId)
    }
}
