//
//  CoffeeSearchViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//

import UIKit
import FirebaseFirestore

class CoffeeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 300
        fetchCafeData()
        tableView.reloadData()
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
        makeLabelOval(cell.tag1)
        makeLabelOval(cell.tag2)
        makeLabelOval(cell.tag3)
        makeLabelOval(cell.tag4)
        cell.coffeeShopImage.contentMode = .scaleAspectFill
        cell.coffeeShopImage.clipsToBounds = true
        
        // Load image asynchronously
        if let imageUrl = coffeeShop.imageUrl {
            loadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    cell.coffeeShopImage.image = image
                }
            }
        } else {
            cell.coffeeShopImage.image = nil
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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


    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
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
