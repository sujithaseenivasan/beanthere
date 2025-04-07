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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
