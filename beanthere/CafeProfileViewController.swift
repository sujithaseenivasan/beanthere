//
//  CafeProfileViewController.swift
//  beanthere
//
//  Created by Sarah Neville on 3/9/25.
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
    var cafeID: String = "3L0v19ibM9bOqE0Ys75YhA" //need to change this to be able to dynamically update it
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCafeData()

        // Do any additional setup after loading the view.
    }
    
    func fetchCafeData() {
        db.collection("coffeeShops").document(cafeID).getDocument { (document, error) in
            if let error = error {
                       // get the specific error
                       print("Error fetching document: \(error.localizedDescription)")
                       return
                   }
            
            if let document, document.exists {
                let data = document.data()
                
                self.cafeNameLabel.text = data?["name"] as? String ?? "No Name"
                self.addressLabel.text = data?["address"] as? String ?? "No address"
                
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

}
