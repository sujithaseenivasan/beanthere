//
//  FriendProfileVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/7/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FriendProfileVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var friendImg: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var friendUserName: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    @IBOutlet weak var followingNum: UILabel!
    
    @IBOutlet weak var friendReviewTableView: UITableView!
    
    var friendID: String?
    var delegate: UIViewController!
    
    let valCellIndetifier = "FriendProfileCellID"
    // Fake review data
    var userReviews:[Review] = []
    var userReviewIDs : [String] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadImage(self.friendImg)
        makeImageOval(self.friendImg)
        
        friendReviewTableView.delegate = self
        friendReviewTableView.dataSource = self
        friendReviewTableView.rowHeight = 150
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        // search in firebase if you find the user populate the users information in the swift fields
//        guard let safeFriendID = friendID else {
//            print("friendID was nil. Cannot fetch userField.")
//            return
//        }
        
        let userField = db.collection("users").document(friendID!)
        userField.getDocument { (docSnap, error) in
            //if user have an error guard it
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            guard let document = docSnap, document.exists else {
                print("User document does not exist")
                return
            }
            
            // Retrieve the fields from the Firestore document
            let data = document.data()
            self.friendUserName.text = data?["username"] as? String ?? " "
            
            self.friendName.text = data?["firstName"] as? String ?? " "
            self.followersNum.text = "\((data?["friendsList"] as? [String])?.count ?? 0)"
            self.followingNum.text = "\((data?["following"] as? [String])?.count ?? 0)"
            
            let reviewIDs: [String] = data?["reviews"] as? [String] ?? []
            //put all the information of currently loaded data in the array of reviews
            print("ENTERED VIEW WILL APPEAR")
            self.fetchUserReviews()
            
        }
    }
    
    func fetchUserReviews() {
           //get the user that is currently logged in
        let userID = self.friendID!
            //if user is currently logged in, use thier userID to fetch their document
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let reviewIDs = document.data()?["reviews"] as? [String] {
                    self.fetchReviewDetails(reviewIDs: reviewIDs)
                    self.userReviewIDs = reviewIDs
                }
            } else {
                print("User document not found")
            }
           }
    }
       
    func fetchReviewDetails(reviewIDs: [String]) {
        let group = DispatchGroup()
        var fetchedReviews: [Review] = []
        var numReviews: Int = 0
        //get each review id
        for reviewID in reviewIDs {
            group.enter()
            db.collection("reviews").document(reviewID).getDocument { (document, error) in
                // Document doesn't exist or there's an error
                guard let document = document, document.exists, let data = document.data() else {
                    group.leave()
                    return
                }
                //from there get the details of the review with the pictures
                var review = Review(
                    coffeeShopID: data["coffeeShopID"] as? String ?? "",
                    comment: data["comment"] as? String ?? "",
                    rating: data["rating"] as? Int ?? 0,
                    tags: data["tags"] as? [String] ?? [],
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    numLikes: data["friendsLikes"] as? Int ?? 0
                    
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
            self.userReviews = fetchedReviews
            self.friendReviewTableView.reloadData()
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
    
    /*when the follow Button is clicked increase the number of followers for the
    friend and the following numbers for the user*/
    @IBAction func followButton(_ sender: Any) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        if let button = sender as? UIButton {
            if(button.titleLabel?.text == "Follow"){
                button.setTitle("Following", for: .normal)
                updateFollowingAndFollowers(for: userUID, friendID: friendID!, DidFollow: true)
            }else {
                button.setTitle("Follow", for: .normal)
                updateFollowingAndFollowers(for: userUID, friendID: friendID!, DidFollow: false)
                self.followersNum.text = String(Int(self.followersNum.text!)! - 1)
            }
            
        }
    }
    
    //function to update the followers and the followings for the users
    func updateFollowingAndFollowers(for userID: String, friendID: String, DidFollow: Bool) {
        let userField = db.collection("users").document(userID)
        let friendField = db.collection("users").document(friendID)
        if(DidFollow){
            self.followersNum.text = String(Int(self.followersNum.text!)! + 1)
            userField.updateData(["friendsList": FieldValue.arrayUnion([friendID])])
            friendField.updateData(["followers": FieldValue.arrayUnion([userID])])
        } else {
            self.followersNum.text = String(Int(self.followersNum.text!)! - 1)
            userField.updateData(["friendsList": FieldValue.arrayRemove([friendID])])
            friendField.updateData(["followers": FieldValue.arrayRemove([userID])])
        }
        
        
        
    }
    
    @IBAction func beenBrewButton(_ sender: Any) {
    }
    
    //segue to view friend's brewlog from their profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendToBeenSegue",
           let tabsVC = segue.destination as? BrewTabsViewController {
            tabsVC.defaultTabIndex = 0 // assuming we want to default to the "Been" tab
            tabsVC.friendID = self.friendID // or however you're storing it
        }
        if segue.identifier == "friendToWantToTrySegue",
           let tabsVC = segue.destination as? BrewTabsViewController {
            tabsVC.defaultTabIndex = 1 // now we are going to "Want to Try" tab
            tabsVC.friendID = self.friendID
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userReview = userReviews[indexPath.row]
        //print ("Entered CellForRowAt at Profile ")
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath) as! FriendProfileTVCell
        if (userReviews.count > 0){
            cell.likeCount = userReview.numLikes ?? 0
            cell.reviewID = userReviewIDs[indexPath.row]
            
            cell.cafeName.text = userReview.coffeeShopName
            cell.cafeAdrr.text = userReview.address
            var cafeRanks = userReview.rating
            //populate the beans given the ranking
            let beans = [cell.bean1, cell.bean2, cell.bean3, cell.bean4, cell.bean5]
            for (index, bean) in beans.enumerated() {
                bean?.image = cafeRanks > index ? UIImage(named: "filled_bean.png") : nil
            }

            cell.comment.text = userReview.comment
            //import a picture using reviewIDs
            globLoadReviewImage(reviewId: userReviewIDs[indexPath.row]){images in
                if let images = images, !images.isEmpty {
                    cell.drinkImg.image = images.first ?? UIImage(named: "beantherelogo")// Show first image
                }
            }
        
            makeImageOval(cell.drinkImg)
            //download image from firebase and display it
            downloadImage(cell.drinkImg)
        }
        return cell
    }

}
