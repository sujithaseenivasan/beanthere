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
        tagContents.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 14)
        tagContents.setTitleColor(.white, for: .normal)
    }
    
    func configure(tag: String, isSelected: Bool, color: UIColor) {
        tagContents.isUserInteractionEnabled = false
        tagContents.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 12)
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
