//
//  RecommendationViewController.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 4/8/25.
//

import UIKit
import FirebaseAuth

class RecommendationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // array to hold the final CoffeeShop objects
    var coffeeShops: [CoffeeShop] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 200
        fetchRecommendations()
    }
    

    func fetchRecommendations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        getUserReviewedShopIDs(for: currentUserID) { userReviewedShopIDs, friendIDs in
            self.getFriendsReviewedShopIDs(friendIDs: friendIDs) { friendShopIDs in
                let recommendationIDs = Array(friendShopIDs.subtracting(userReviewedShopIDs).prefix(10))
                print("User reviewed: \(userReviewedShopIDs)")
                print("Friends reviewed: \(friendShopIDs)")
                print("Recommended shop IDs: \(recommendationIDs)")
                self.fetchCoffeeShopDetails(shopIDs: recommendationIDs)
            }
        }
    }

    
    func getUserReviewedShopIDs(for userID: String, completion: @escaping (Set<String>, [String]) -> Void) {
        // reference to the user's document and the reviews collection
        let userRef = db.collection("users").document(userID)
        let reviewsRef = db.collection("reviews")
        // set to store unique coffeeShopIDs that the user has reviewed
        var reviewedShopIDs = Set<String>()

        // get the user's document from Firestore
        userRef.getDocument { (snapshot, error) in
            // get the review IDs, and friend IDs
            guard let data = snapshot?.data(),
                  let reviewIDs = data["reviews"] as? [String],
                  let friendIDs = data["friendsList"] as? [String] else {
                // if any part fails, return empty results
                completion([], [])
                return
            }
            // use DispatchGroup to wait for all review fetches to complete
            let group = DispatchGroup()

            // for each review ID, fetch the review and get the coffeeShopID
            for reviewID in reviewIDs {
                group.enter()
                reviewsRef.document(reviewID).getDocument { reviewSnapshot, _ in
                    if let reviewData = reviewSnapshot?.data(),
                       let shopID = reviewData["coffeeShopID"] as? String {
                        // add the shop ID to the set
                        reviewedShopIDs.insert(shopID)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                // return the set of reviewed shop IDs and the friend list
                completion(reviewedShopIDs, friendIDs)
            }
        }
    }
    
    // fetches the set of unique coffeeShopIDs that the user's friends have reviewed.
    func getFriendsReviewedShopIDs(friendIDs: [String], completion: @escaping (Set<String>) -> Void) {
        let reviewsRef = db.collection("reviews")
        // set to store all unique coffeeShopIDs reviewed by friends
        var friendShopIDs = Set<String>()
        let group = DispatchGroup()

        // loop through each friend
        for friendID in friendIDs {
            group.enter()
            // fetch the friend's user document to get their list of review IDs
            db.collection("users").document(friendID).getDocument { snapshot, _ in
                guard let data = snapshot?.data(),
                      let reviewIDs = data["reviews"] as? [String] else {
                    group.leave()
                    return
                }
                // inner group to wait for all reviews of this friend to be fetched
                let innerGroup = DispatchGroup()
                // fetch each review and get the coffeeShopID
                for reviewID in reviewIDs {
                    innerGroup.enter()
                    reviewsRef.document(reviewID).getDocument { reviewSnapshot, _ in
                        if let reviewData = reviewSnapshot?.data(),
                           let shopID = reviewData["coffeeShopID"] as? String {
                            friendShopIDs.insert(shopID)
                        }
                        innerGroup.leave()
                    }
                }

                innerGroup.notify(queue: .main) {
                    group.leave()
                }
            }
        }
        // once all friend documents and their reviews are processed return the result
        group.notify(queue: .main) {
            completion(friendShopIDs)
        }
    }
    
    func fetchCoffeeShopDetails(shopIDs: [String]) {
        // clear the previous list
        self.coffeeShops = []

        let group = DispatchGroup()
        //loop through each coffee shop
        for shopID in shopIDs {
            group.enter()
            db.collection("coffeeShops").document(shopID).getDocument { snapshot, _ in
                if let data = snapshot?.data() {
                    //create CoffeeShop object and add it to the list
                    let shop = CoffeeShop(id: shopID, data: data)
                    self.coffeeShops.append(shop)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            // TODO: could reload UI here or check if the table is empty
            self.tableView.reloadData()
            print("Fetched all recommended coffee shops.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Row count: \(coffeeShops.count)")
        return coffeeShops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as! RecommendationTableViewCell
        
        let shop = coffeeShops[indexPath.row]
        cell.coffeeShopName.text = shop.name
        cell.address.text = shop.address
        
        // clear old image
        cell.cafeImage.image = nil
        if let imageUrl = shop.imageUrl {
            cell.loadImage(from: imageUrl)
        }
        return cell
    }
    
    //when you select a row, takes you to the cafe profile
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
