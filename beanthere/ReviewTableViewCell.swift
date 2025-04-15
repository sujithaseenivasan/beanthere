//
//  ReviewTableViewCell.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/2/25.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var reviewNotes: UILabel!
    
    @IBOutlet var reviewTagLabels: [UILabel]!

    @IBOutlet weak var imageOne: UIImageView!
    
    @IBOutlet weak var imageTwo: UIImageView!
    
    @IBOutlet weak var beanImageView1: UIImageView!
    @IBOutlet weak var beanImageView2: UIImageView!
    @IBOutlet weak var beanImageView3: UIImageView!
    @IBOutlet weak var beanImageView4: UIImageView!
    @IBOutlet weak var beanImageView5: UIImageView!
        
    // An array to easily access the beans
    var beanImageViews: [UIImageView] {
        return [beanImageView1, beanImageView2, beanImageView3, beanImageView4, beanImageView5]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userName.font = UIFont(name: "Lora-Bold", size: 20)
        reviewNotes.font = UIFont(name: "Lora-SemiBold", size: 14)
        
        reviewTagLabels.forEach {
            $0.font = UIFont(name: "Lora-SemiBold", size: 10)
        }

        for bean in beanImageViews {
            bean.image = nil
        }
    }
}
