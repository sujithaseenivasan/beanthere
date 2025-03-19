//
//  TagCell.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/18/25.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagContents: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    func configure(tag: String, isSelected: Bool, color: UIColor) {
        tagContents.isUserInteractionEnabled = false
        contentView.backgroundColor = isSelected ? color : UIColor(named: "UnselectedTag")

        if isSelected {
            tagContents.setTitle(tag, for: .normal)
        } else {
            tagContents.setTitle("+ " + tag, for: .normal)
        }

        tagContents.sizeToFit()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
    }
}
