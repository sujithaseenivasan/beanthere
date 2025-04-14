//
//  UILabelPadding.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/13/25.
//
import UIKit
// MARK: - UILabel Padding Extension
extension UILabel {
    func padding(left: CGFloat, right: CGFloat) {
        if let currentConstraints = self.constraints.first(where: { $0.firstAttribute == .width }) {
            self.removeConstraint(currentConstraints)
        }
        let insets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
        let paddedWidth = self.intrinsicContentSize.width + insets.left + insets.right
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: paddedWidth).isActive = true
    }
}

