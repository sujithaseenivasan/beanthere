//
//  Review.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 4/1/25.
//

import Foundation

struct Review {
    let reviewID: String
    let coffeeShopID: String
    var coffeeShopName: String?
    var address: String?
    let comment: String
    let rating: Int
    let tags: [String]
    let timestamp: Date
    let numLikes: Int?
}
