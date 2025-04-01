//
//  BrewLogViewController.swift
//  beanthere
//
//  Created by Sarah Neville on 4/1/25.
//

import UIKit
import FirebaseFirestore

class BrewLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    let tableCellIdentifier = "BrewLogCell"
    
    //array to store fetched reviews
    var reviews: [Review] = []
    let db = Firestore.firestore()
    let userID = "U1KQYXg9igZhGcDaQWIUBMe0nX53" // Replace with dynamic user ID

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUserReviews()
        // Do any additional setup after loading the view.
    }
    
    func fetchUserReviews() {
        //get the list of review IDs for the current user
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let reviewIDs = document.data()?["reviews"] as? [String] {
                    self.fetchReviewDetails(reviewIDs: reviewIDs)
                }
            } else {
                print("User document not found")
            }
        }
    }
    
    func fetchReviewDetails(reviewIDs: [String]) {
        let group = DispatchGroup()
        var fetchedReviews: [Review] = []
        //loop through each of the reviews
        for reviewID in reviewIDs {
            group.enter()
            db.collection("reviews").document(reviewID).getDocument { (document, error) in
                defer { group.leave() }
                //put the Firestore data into Review struct
                if let document = document, document.exists, let data = document.data() {
                    var review = Review(
                        coffeeShopID: data["coffeeShopID"] as? String ?? "",
                        comment: data["comment"] as? String ?? "",
                        rating: data["rating"] as? Int ?? 0,
                        tags: data["tags"] as? [String] ?? [],
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    
                    group.enter()
                    //get the name of the coffee shop and the address based on the coffeeShopID
                    //and add it to the struct
                    self.fetchCoffeeShopDetails(for: review.coffeeShopID) { name, address in
                        review.coffeeShopName = name
                        review.address = address
                        //add review to our temp array
                        fetchedReviews.append(review)
                        group.leave()
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            //once all the reviews are fetched, update the main array
            self.reviews = fetchedReviews
            self.tableView.reloadData()
        }
    }
    
    //helper function that grabs the name and address for a particular coffeeShopID
    func fetchCoffeeShopDetails(for coffeeShopID: String, completion: @escaping (String?, String?) -> Void) {
        db.collection("coffeeShops").document(coffeeShopID).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let name = data["name"] as? String
                let address = data["address"] as? String
                completion(name, address)
            } else {
                completion(nil, nil)
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrewLogCell", for: indexPath) as! BrewLogCell
        let review = reviews[indexPath.row]
        cell.coffeeShopName.text = review.coffeeShopName
        cell.addressLabel.text = review.address
        cell.notes.text = review.comment
        
        cell.bean1.isHidden = review.rating < 1
        cell.bean2.isHidden = review.rating < 2
        cell.bean3.isHidden = review.rating < 3
        cell.bean4.isHidden = review.rating < 4
        cell.bean5.isHidden = review.rating < 5
        
        return cell
    }

}
