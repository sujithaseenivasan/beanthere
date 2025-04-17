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

class FriendProfileVC: UIViewController,UITableViewDelegate, UITableViewDataSource, FriendProfileTableViewCellDel {
    
    @IBOutlet weak var friendImg: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var friendUserName: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    @IBOutlet weak var followingNum: UILabel!
    @IBOutlet weak var friendReviewTableView: UITableView!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var followerDummy: UILabel!
    @IBOutlet weak var followingDummy: UILabel!
    @IBOutlet weak var been: UILabel!
    @IBOutlet weak var wantToTry: UILabel!
    @IBOutlet weak var recentActivities: UILabel!
    
    var friendID: String?
    var delegate: UIViewController!
    var myUserName: String?
    let valCellIndetifier = "FriendProfileCellID"
    // Fake review data
    var userReviews:[Review] = []
    var userReviewIDs : [String] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeFonts()
        
        friendReviewTableView.delegate = self
        friendReviewTableView.dataSource = self
        friendReviewTableView.rowHeight = 150
        
        // populate the friends picture
        fetchUserImage(userId: self.friendID!){image in
            if let image = image {
                DispatchQueue.main.async {
                    print("IN FRIEND FRIEND ID IS \(self.friendID!)")
                    self.friendImg.image = image
                }
            }else {
                self.friendImg.image = nil
            }
        }
        makeImageOval(self.friendImg)
        
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        populateUserName()
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
            let firstName = data?["firstName"] as? String ?? ""
            let lastName = data?["lastName"] as? String ?? ""
            var tempUserName: String = "@" + firstName + lastName
            
            self.friendUserName.text = tempUserName
            self.friendName.text = firstName
            self.followersNum.text = "\((data?["friendsList"] as? [String])?.count ?? 0)"
            self.followingNum.text = "\((data?["following"] as? [String])?.count ?? 0)"
            
            let reviewIDs: [String] = data?["reviews"] as? [String] ?? []
            //put all the information of currently loaded data in the array of reviews
            print("ENTERED VIEW WILL APPEAR")
            self.fetchUserReviews()
            
        }
    }
    
    //function that changes fonts
    func changeFonts(){
        friendName.font = UIFont(name: "Lora-Bold", size: 17)
        friendUserName.font = UIFont(name: "Lora-Regular", size: 15)
        followersNum.font = UIFont(name: "Lora-Regular", size: 14)
        followingNum.font = UIFont(name: "Lora-Regular", size: 14)
        followerDummy.font = UIFont(name: "Lora-Regular", size: 15)
        followingDummy.font = UIFont(name: "Lora-Regular", size: 15)
        been.font = UIFont(name: "Lora-SemiBold", size: 22)
        wantToTry.font = UIFont(name: "Lora-SemiBold", size: 22)
        recentActivities.font = UIFont(name: "Lora-SemiBold", size: 17)
        follow.titleLabel?.font = UIFont(name: "Lora-Bold", size: 15)
    }
    
    // function that populates the user name
    func populateUserName(){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let userName = document.data()?["firstName"] as? String {
                    self.myUserName = userName
                    print("MY USERNAME IS INSIDE \(self.myUserName)")
                }
            }
        }
    }
    
    // functions that fetches userImages from firebase
    func fetchUserImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage()
        let imagePath = "images/\(userId)_file.png"
        let imagePath2 = "images/\(userId)file.png"
        let imageRef = storage.reference(withPath: imagePath)
        let imageRef2 = storage.reference(withPath: imagePath2)

        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                imageRef2.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        print("Image fetched 2successfully.")
                        completion(image)
                    } else {
                        print("Failed2 to convert data to image.")
                        completion(nil)
                    }
                }
                return
            }

            if let data = data, let image = UIImage(data: data) {
                print("Image fetched successfully.")
                completion(image)
            } else {
                print("Failed to convert data to image.")
                completion(nil)
            }
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
                    self.friendReviewTableView.reloadData()
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
                    reviewID: document.documentID,
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
            self.followersNum.text = String(max((Int(self.followersNum.text!) ?? 0) - 1, 0))
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
        
        if segue.identifier == "friendCommentSegue",
               let commentVC = segue.destination as? CommentPopUpVC,
                  let reviewID = sender as? String {
            print("ENTERED PREPARE FOR SEGUE \(reviewID)")
            print("MY USERNAME IS \(myUserName)")
            commentVC.delegate = self
            commentVC.reviewID = reviewID
            commentVC.userName = self.myUserName
            print("ENTERED PREPARE FOR SEGUE PASSED \(commentVC.reviewID)")

            commentVC.modalPresentationStyle = .overCurrentContext
            self.definesPresentationContext = true
        }
        
    }
    
    func didTapCommentButton2(reviewID: String) {
        print("ENTERED DID TAP IN FRIEND VC ")
        performSegue(withIdentifier: "friendCommentSegue", sender: reviewID)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userReview = userReviews[indexPath.row]
        //print ("Entered CellForRowAt at Profile ")
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath) as! FriendProfileTVCell
        if (userReviews.count > 0){
            cell.changeFonts()
            cell.delegate = self
            cell.likeCount = userReview.numLikes ?? 0
            cell.reviewID = userReviewIDs[indexPath.row]
            cell.cafeName.text = userReview.coffeeShopName
            cell.cafeAdrr.text = userReview.address
            cell.userRankName.text = self.friendName.text
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
