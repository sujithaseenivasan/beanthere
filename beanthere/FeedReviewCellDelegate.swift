//
//  FeedReviewCellDelegate.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/9/25.
//

import Foundation

protocol FeedReviewCellDelegate: AnyObject {
    func didTapLikeButton(for reviewId: String)
}
