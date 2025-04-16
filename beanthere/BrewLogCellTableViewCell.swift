//
//  BrewLogCellTableViewCell.swift
//  beanthere
//
//  Created by Sarah Neville on 4/7/25.
//

import UIKit

class BrewLogCellTableViewCell: UITableViewCell {

    @IBOutlet weak var bean5: UIImageView!
    @IBOutlet weak var bean4: UIImageView!
    @IBOutlet weak var bean3: UIImageView!
    @IBOutlet weak var bean2: UIImageView!
    @IBOutlet weak var bean1: UIImageView!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var coffeeShopName: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //coffeeShopName.font = UIFont(name: "Lora-Bold", size: 20)
        notes.font = UIFont(name: "Lora-Medium", size: 15)
        addressLabel.font = UIFont(name: "Lora", size: 15)
        coffeeShopName.font = UIFont(name: "Lora-SemiBold", size: 17)
        commentLabel.font = UIFont(name: "Lora-Medium", size: 15)
        rankLabel.font = UIFont(name: "Lora-Medium", size: 15)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
