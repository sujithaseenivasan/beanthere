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
}
