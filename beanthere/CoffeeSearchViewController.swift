//
//  CoffeeSearchViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/10/25.
//

import UIKit
import FirebaseFirestore

class CoffeeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableCellIdentifier = "CoffeeSearchCell"

    let db = Firestore.firestore()
    // Array to store fetched coffee shop data
    var fetchedResults: [CoffeeShop] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    var initialSearchText: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = initialSearchText
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
        db.collection("coffeeShops").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            // Clear old results
            self.fetchedResults.removeAll()

            // Parse documents
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let coffeeShop = CoffeeShop(
                        name: data["name"] as? String ?? "No Name",
                        address: data["address"] as? String ?? "No Address",
                        tags: data["tags"] as? [String] ?? [],
                        description: data["description"] as? String ?? "No Description",
                        imageUrl: data["image_url"] as? String ?? ""
                    )
                    
                    self.fetchedResults.append(coffeeShop)
                }
                
                // Reload table view on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! CoffeeSearchCell
        
        let coffeeShop = fetchedResults[indexPath.row]
        
        cell.coffeeShopName.text = coffeeShop.name
        cell.address.text = coffeeShop.address
        cell.cafeDescription.text = coffeeShop.description
        
        // Load image asynchronously
        if let imageUrl = coffeeShop.imageUrl {
            loadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    cell.coffeeShopImage.image = image
                }
            }
        } else {
            cell.coffeeShopImage.image = nil // Set a placeholder or leave blank
        }
        
        return cell
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


}
