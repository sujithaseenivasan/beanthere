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
    
    convenience init(id: String, data: [String: Any]) {
        let name = data["name"] as? String ?? "Unnamed"
        let address = data["address"] as? String ?? "No address"
        let tags = data["tags"] as? [String] ?? []
        let description = data["description"] as? String ?? ""
        let imageUrl = data["image_url"] as? String ?? ""

        self.init(documentId: id, name: name, address: address, tags: tags, description: description, imageUrl: imageUrl)
    }

}
