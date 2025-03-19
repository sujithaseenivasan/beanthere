//
//  CafeProfileViewController.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 3/9/25.
//

import UIKit
import FirebaseFirestore

class CafeProfileViewController: UIViewController {

    
    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagLabel3: UILabel!
    @IBOutlet weak var tagLabel2: UILabel!
    @IBOutlet weak var tagLabel1: UILabel!
    @IBOutlet weak var tagLabel4: UILabel!
    
    //firestore instance
    let db = Firestore.firestore()
    var cafeId: String?
    
    let addReviewSegueIdentifier = "addReviewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //adjust font size to fit into label
        cafeNameLabel.adjustsFontSizeToFitWidth = true
        cafeNameLabel.minimumScaleFactor = 0.5
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.5
        
        // allow description to go to multiple lines
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        makeLabelOval(tagLabel1)
        makeLabelOval(tagLabel2)
        makeLabelOval(tagLabel3)
        makeLabelOval(tagLabel4)
        
        // make image fill the UIImageView space
        cafeImage.contentMode = .scaleAspectFill
        cafeImage.clipsToBounds = true
        
        fetchCafeData()

        // Do any additional setup after loading the view.
    }
    
    func fetchCafeData() {
        guard let cafeId = cafeId else {
                print("Error: cafeId is nil in CafeProfileViewController")
                return
            }
            
        print("Fetching data for cafeId: \(cafeId)") // Debugging
        
        db.collection("coffeeShops").document(cafeId).getDocument { (document, error) in
            if let error = error {
                       // get the specific error
                       print("Error fetching document: \(error.localizedDescription)")
                       return
                   }
            
            if let document, document.exists {
                let data = document.data()
                
                self.cafeNameLabel.text = data?["name"] as? String ?? "No Name"
                self.addressLabel.text = data?["address"] as? String ?? "No address"
                self.descriptionLabel.text = data?["description"] as? String ?? "No description"
                
                if let imageUrl = data?["image_url"] as? String {
                    self.loadImage(from: imageUrl)
                }
            }
            else {
                print("Document does not exist.")
            }
        }
    }
    
    //load image function
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
    
    // helper function to make labels oval
    func makeLabelOval(_ label: UILabel) {
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addReviewSegueIdentifier {
            if let destinationVC = segue.destination as? AddReviewViewController {
                destinationVC.cafeId = self.cafeId
            }
        }
    }

}
