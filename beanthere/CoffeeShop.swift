//
//  CoffeeShop.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//


class CoffeeShop {
    var name: String
    var address: String
    var tags: [String]
    var description: String
    var imageUrl: String?
    
    init(name: String, address: String, tags: [String], description: String, imageUrl: String) {
        self.name = name
        self.address = address
        self.tags = tags
        self.description = description
        self.imageUrl = imageUrl
    }
}
