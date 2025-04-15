//
//  TagStyler.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/13/25.
//

import UIKit

struct TagStyler {
    static func configureTagLabels(_ labels: [UILabel], withTags tags: [String]) {
        let colors: [UIColor] = [
            UIColor(named: "TagColor1") ?? .red,
            UIColor(named: "TagColor2") ?? .blue,
            UIColor(named: "TagColor3") ?? .green,
            UIColor(named: "TagColor4") ?? .orange,
            UIColor(named: "TagColor5") ?? .purple
        ]

        let sortedTags = tags.sorted()
        let limitedTags = Array(sortedTags.prefix(4))

        if limitedTags.isEmpty {
            for (index, label) in labels.enumerated() {
                if index == 0 {
                    label.text = "No tags yet"
                    label.isHidden = false
                    label.backgroundColor = .lightGray
                    label.textColor = .white
                    label.font = UIFont(name: "Lora-SemiBold", size: 10)
                    label.textAlignment = .center
                    label.layer.cornerRadius = 10
                    label.layer.masksToBounds = true
                    label.adjustsFontSizeToFitWidth = true
                    label.minimumScaleFactor = 0.85
                    label.setContentHuggingPriority(.required, for: .horizontal)
                    label.setContentCompressionResistancePriority(.required, for: .horizontal)
                    label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
                    label.padding(left: 10, right: 10)
                } else {
                    label.text = ""
                    label.isHidden = true
                }
            }
            labels.first?.superview?.layoutIfNeeded()
            return
        }

        for (index, label) in labels.enumerated() {
            if index < limitedTags.count {
                label.text = limitedTags[index]
                label.isHidden = false
                label.backgroundColor = colors[index % colors.count]
                label.textColor = .white
                label.font = UIFont(name: "Lora-SemiBold", size: 10)
                label.textAlignment = .center
                label.layer.cornerRadius = label.layer.frame.height > 0 ? label.layer.frame.height / 2 : 10
                label.layer.masksToBounds = true
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.85
                label.setContentHuggingPriority(.required, for: .horizontal)
                label.setContentCompressionResistancePriority(.required, for: .horizontal)
                label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
                label.padding(left: 10, right: 10)
            } else {
                label.text = ""
                label.isHidden = true
            }
        }

        labels.first?.superview?.layoutIfNeeded()
    }
}
