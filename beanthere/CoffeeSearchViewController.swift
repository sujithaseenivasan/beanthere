//
//  CoffeeSearchViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//

import UIKit
import FirebaseFirestore

class CoffeeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let tableCellIdentifier = "CoffeeSearchCell"
    let cafeProfileSegueIdentifier = "cafeProfileSegueIdentifier"

    let db = Firestore.firestore()
    
    var allResults: [CoffeeShop] = []
    var filteredResults: [CoffeeShop] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    var initialSearchText: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = initialSearchText
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 310
        fetchCafeData()
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
        fetchCafeData()
        tableView.reloadData()
    }
    

    func fetchCafeData() {
        activityIndicator.startAnimating()
        db.collection("coffeeShops").getDocuments { (snapshot, error) in
            
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            // Clear old results
            self.allResults.removeAll()

            // Parse documents
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let coffeeShop = CoffeeShop(
                        documentId: document.documentID,
                        name: data["name"] as? String ?? "No Name",
                        address: data["address"] as? String ?? "No Address",
                        tags: data["tags"] as? [String] ?? [],
                        description: data["description"] as? String ?? "No Description",
                        imageUrl: data["image_url"] as? String ?? ""
                    )
                    
                    self.allResults.append(coffeeShop)
                }
                
                self.filteredResults = self.allResults
                
                // Reload table view on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.activityIndicator.stopAnimating()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! CoffeeSearchCell
        
        let coffeeShop = filteredResults[indexPath.row]
        
        cell.coffeeShopName.adjustsFontSizeToFitWidth = true
        cell.coffeeShopName.minimumScaleFactor = 0.5
        cell.address.adjustsFontSizeToFitWidth = true
        cell.address.minimumScaleFactor = 0.5
        cell.coffeeShopName.text = coffeeShop.name
        cell.address.text = coffeeShop.address
        cell.cafeDescription.text = coffeeShop.description
        cell.coffeeShopImage.contentMode = .scaleAspectFill
        cell.coffeeShopImage.clipsToBounds = true
        
        // Load image asynchronously
        if let imageUrl = coffeeShop.imageUrl {
            FirebaseUtil.loadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    cell.coffeeShopImage.image = image
                }
            }
        } else {
            cell.coffeeShopImage.image = nil
        }
        
        let db = Firestore.firestore()
        db.collection("coffeeShops").document(coffeeShop.documentId).getDocument { docSnapshot, error in
            guard let doc = docSnapshot, error == nil, let data = doc.data(),
                  let reviewIds = data["reviews"] as? [String] else {
                TagStyler.configureTagLabels(cell.reviewTagLabels, withTags: [])
                return
            }

            var tagFrequency: [String: Int] = [:]
            var totalRating = 0
            var ratingCount = 0

            let dispatchGroup = DispatchGroup()

            for reviewId in reviewIds {
                dispatchGroup.enter()
                db.collection("reviews").document(reviewId).getDocument { reviewDoc, error in
                    defer { dispatchGroup.leave() }

                    if let reviewData = reviewDoc?.data() {
                        // Aggregate tags
                        if let tags = reviewData["tags"] as? [String] {
                            for tag in tags {
                                tagFrequency[tag, default: 0] += 1
                            }
                        }

                        // Aggregate rating
                        if let rating = reviewData["rating"] as? Int {
                            totalRating += rating
                            ratingCount += 1
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Calculate average rating
                let averageRating = ratingCount > 0 ? Double(totalRating) / Double(ratingCount) : 0.0
                self.updateBeanRatingDisplay(for: cell.cafeBeanImageViews, average: averageRating)

                // Compute top tags
                let sortedTags = tagFrequency.sorted { $0.value > $1.value }
                let topTags = Array(sortedTags.prefix(4).map { $0.key })

                TagStyler.configureTagLabels(cell.reviewTagLabels, withTags: topTags)
            }
        }


        
        return cell
    }

    
    func updateBeanRatingDisplay(for imageViews: [UIImageView], average: Double) {
        for (index, imageView) in imageViews.enumerated() {
            let ratingPosition = Double(index)

            if ratingPosition + 1 <= average {
                imageView.image = UIImage(named: "filled_bean.png")
            } else if ratingPosition < average {
                imageView.image = UIImage(named: "filled_bean.png")
            } else {
                imageView.image = UIImage(named: "unfilled_bean.png")
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCoffeeShop = filteredResults[indexPath.row]

        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)
        if let cafeProfileVC = storyboard.instantiateViewController(withIdentifier: "CafeProfileViewController") as? CafeProfileViewController {
            
            cafeProfileVC.cafeId = selectedCoffeeShop.documentId
            
            navigationController?.pushViewController(cafeProfileVC, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == cafeProfileSegueIdentifier {
            if let destinationVC = segue.destination as? CafeProfileViewController,
               let selectedCoffeeShop = sender as? CoffeeShop {
                destinationVC.cafeId = selectedCoffeeShop.documentId
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText.isEmpty {
              filteredResults = allResults
          } else {
              filteredResults = allResults.filter { cafe in
                  cafe.name.lowercased().contains(searchText.lowercased()) ||
                  cafe.address.lowercased().contains(searchText.lowercased()) ||
                  cafe.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
              }
          }
          tableView.reloadData()
      }
    
    func makeLabelOval(_ label: UILabel) {
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
    }


}
