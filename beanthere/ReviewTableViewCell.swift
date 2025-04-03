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
    
    @IBOutlet weak var tagOne: UILabel!
    
    @IBOutlet weak var tagTwo: UILabel!
    
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
            // Initial setup for the beans if needed
            for bean in beanImageViews {
                bean.image = nil // Start with no beans
            }
        }
}
