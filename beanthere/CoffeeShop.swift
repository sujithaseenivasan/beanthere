//
//  CoffeeShop.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//


class CoffeeShop {
    var documentId: String
    var name: String
    var address: String
    var tags: [String]
    var description: String
    var imageUrl: String?
    
    init(documentId: String, name: String, address: String, tags: [String], description: String, imageUrl: String) {
        self.documentId = documentId
        self.name = name
        self.address = address
        self.tags = tags
        self.description = description
        self.imageUrl = imageUrl
    }
}
