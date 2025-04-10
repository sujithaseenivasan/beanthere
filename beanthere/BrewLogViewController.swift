//
//  BrewLogViewController.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 4/1/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class BrewLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    let tableCellIdentifier = "BrewLogCell"
    
    //array to store fetched reviews
    var reviews: [Review] = []
    let db = Firestore.firestore()
    
    //if we are viewing another user's brewlog
    var friendID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 300  // any reasonable guess
        tableView.rowHeight = 100
        
        fetchUserReviews()
        // Do any additional setup after loading the view.
    }
    
    func fetchUserReviews() {
        // Use friendID if passed in, otherwise fallback to current user's UID
        guard let uidToUse = friendID ?? Auth.auth().currentUser?.uid else {
            print("No user is logged in and no friend ID was provided")
            return
        }

        // fetch the user's document from Firestore
        db.collection("users").document(uidToUse).getDocument { (document, error) in
            if let document = document, document.exists {
                if let reviewIDs = document.data()?["reviews"] as? [String] {
                    self.fetchReviewDetails(reviewIDs: reviewIDs)
                } else {
                    print("No reviews found in user document")
                }
            } else {
                print("User document not found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    
    func fetchReviewDetails(reviewIDs: [String]) {
        let group = DispatchGroup()
        var fetchedReviews: [Review] = []

        for reviewID in reviewIDs {
            group.enter()
            db.collection("reviews").document(reviewID).getDocument { (document, error) in
                // Document doesn't exist or there's an error
                guard let document = document, document.exists, let data = document.data() else {
                    group.leave()
                    return
                }

                var review = Review(
                    coffeeShopID: data["coffeeShopID"] as? String ?? "",
                    comment: data["comment"] as? String ?? "",
                    rating: data["rating"] as? Int ?? 0,
                    tags: data["tags"] as? [String] ?? [],
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    numLikes: 0
                )

                self.fetchCoffeeShopDetails(for: review.coffeeShopID) { name, address in
                    review.coffeeShopName = name
                    review.address = address
                    fetchedReviews.append(review)
                    group.leave() // only called here after everything is done
                }
            }
        }

        group.notify(queue: .main) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrewLogCell", for: indexPath) as! BrewLogCellTableViewCell
        let review = reviews[indexPath.row]
        cell.coffeeShopName.text = review.coffeeShopName
        cell.addressLabel.text = review.address
        cell.notes.text = review.comment
        print(review.rating)
        cell.bean1.isHidden = review.rating < 1
        cell.bean2.isHidden = review.rating < 2
        cell.bean3.isHidden = review.rating < 3
        cell.bean4.isHidden = review.rating < 4
        cell.bean5.isHidden = review.rating < 5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the selected coffee shop from reviews
        let selectedCoffeeShop = reviews[indexPath.row]
        
        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)
        
        if let cafeProfileVC = storyboard.instantiateViewController(withIdentifier: "CafeProfileViewController") as? CafeProfileViewController {
            
            // pass the selected shop's ID to the next screen
            cafeProfileVC.cafeId = selectedCoffeeShop.coffeeShopID
            
            // push the profile screen onto the navigation stack
            navigationController?.pushViewController(cafeProfileVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
