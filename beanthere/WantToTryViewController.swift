//
//  WantToTryViewController.swift
//  beanthere
//
//  Created by Sarah Neville on 4/7/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class WantToTryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var coffeeShops: [CoffeeShop] = []
    let db = Firestore.firestore()
    
    //if we are viewing another users brewlog
    var friendID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
        fetchWantToTry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        fetchWantToTry()
    }
    
    func fetchWantToTry() {
        // Use friendID if passed in, otherwise use current user
        guard let uidToUse = friendID ?? Auth.auth().currentUser?.uid else {
            print("No user logged in and no friend ID provided.")
            return
        }
        //get the users data
        db.collection("users").document(uidToUse).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let coffeeShopIDs = data?["wantToTry"] as? [String] ?? []

                self.fetchShopsFromIDs(coffeeShopIDs)
            } else {
                print("User document not found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func fetchShopsFromIDs(_ ids: [String]) {
        let group = DispatchGroup()
        //temporary array to hold fetched CoffeeShops objects
        var fetchedShops: [CoffeeShop] = []
        
        //loop through all the IDs in the array
        for id in ids {
            group.enter()
            //find the document corresponding to the given ID
            db.collection("coffeeShops").document(id).getDocument { (doc, error) in
                defer { group.leave() }
                if let doc = doc, doc.exists, let data = doc.data() {
                    //create a coffeeshop object from the firestore data
                    let shop = CoffeeShop(
                        documentId: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        address: data["address"] as? String ?? "No address",
                        tags: data["tags"] as? [String] ?? [],
                        description: data["description"] as? String ?? "",
                        imageUrl: data["imageUrl"] as? String ?? ""
                    )
                    //append to our temp array
                    fetchedShops.append(shop)
                }
            }
        }
        group.notify(queue: .main) {
            //update the table and the main array
            self.coffeeShops = fetchedShops
            self.tableView.reloadData()
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coffeeShops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shop = coffeeShops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WantToTryCell", for: indexPath)
        //the coffee shop name label
        cell.textLabel?.text = shop.name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        //the address label
        cell.detailTextLabel?.text = shop.address
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    //TODO: add when you click on a cell to take it to that cafe profile
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCoffeeShop = coffeeShops[indexPath.row]

        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)

        if let cafeProfileVC = storyboard.instantiateViewController(withIdentifier: "CafeProfileViewController") as? CafeProfileViewController {
            
            // pass the selected coffee shop’s document ID to the next screen
            cafeProfileVC.cafeId = selectedCoffeeShop.documentId

            // push the profile view controller
            navigationController?.pushViewController(cafeProfileVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
