//
//  RecommendationTableViewCell.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 4/14/25.
//

import UIKit

class RecommendationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cafeImage: UIImageView!
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var coffeeShopName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cafeImage.contentMode = .scaleAspectFill
        cafeImage.clipsToBounds = true
        
        coffeeShopName.font = UIFont(name: "Lora-SemiBold", size: 17)
        address.font = UIFont(name: "Lora-Medium", size: 15)
        //rankLabel.font = UIFont(name: "Lora-Medium", size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImage(from urlString: String) {
        //ensure URL is valid
        guard let url = URL(string: urlString) else { return }
        //try to download image data
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                //update the UI
                DispatchQueue.main.async {
                    self.cafeImage.image = image
                }
            }
        }
    }
    
    

}
