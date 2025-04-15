//
//  CoffeeSearchCell.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//

import UIKit

class CoffeeSearchCell: UITableViewCell {
    
    @IBOutlet weak var coffeeShopImage: UIImageView!
    
    @IBOutlet weak var coffeeShopName: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet var reviewTagLabels: [UILabel]!
    
    @IBOutlet var cafeBeanImageViews: [UIImageView]!
    
    @IBOutlet weak var cafeDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coffeeShopName.font = UIFont(name: "Lora-Bold", size: 20)
        address.font = UIFont(name: "Lora-SemiBold", size: 14)
        cafeDescription.font = UIFont(name: "Lora-Medium", size: 14)
        
        reviewTagLabels.forEach {
            $0.font = UIFont(name: "Lora-SemiBold", size: 10)
        }
    }
}
