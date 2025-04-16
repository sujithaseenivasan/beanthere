//
//  MainUserProfileVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/2/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


class MainUserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PassUserInfoToProfileView, MainProfileTableViewCellDel{
    
    
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var userProfileUsername: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    
    @IBOutlet weak var followingsNum: UILabel!
    
    @IBOutlet weak var userReviewsTableView: UITableView!
    //firestore instance
    let db = Firestore.firestore()
    var userID : String?
    let valCellIndetifier = "UserProfileCellID"
    let addReviewSegueIdentifier = "addReviewSegue"
    let userSettingsSegueIdentifier = "userSettingSegue"
    // Fake review data
    var userReviews:[Review] = []
    var userReviewIDs : [String] = []
    @IBOutlet weak var innerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // from firebase download the image and make it round
        downloadImage(self.userProfileImg)
        makeImageOval(self.userProfileImg)
        
        userReviewsTableView.delegate = self
        userReviewsTableView.dataSource = self
        userReviewsTableView.rowHeight = 150
        
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure there's a logged-in user
        if let profileUID = Auth.auth().currentUser?.uid {
            self.userID = profileUID
            
            let userField = Firestore.firestore().collection("users").document(profileUID)
            
            userField.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    self.userProfileUsername.text = data?["username"] as? String ?? " "
                    self.profileName.text = data?["firstName"] as? String ?? " "
                    self.followersNum.text = "\((data?["friendsList"] as? [String])?.count ?? 0)"
                    self.followingsNum.text = "\((data?["following"] as? [String])?.count ?? 0)"
                    let reviewIDs: [String] = data?["reviews"] as? [String] ?? []
                    // You might want to store these review IDs if needed
                    print("User review IDs: \(reviewIDs)")
                    
                    print("ENTERED VIEW WILL APPEAR")
                    self.fetchUserReviews()
                } else {
                    print("User document not found or error: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        } else {
            print("No authenticated user found")
        }
    }

    
    //overwrite do the connection  between the 2 screens and the main screen
    override func prepare( for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == userSettingsSegueIdentifier,
           let userProfileVC = segue.destination as? UserProfileVC{
            userProfileVC.delegate =  self
        } else if segue.identifier == "userCommentSegue",
               let commentVC = segue.destination as? CommentPopUpVC,
                  let reviewID = sender as? String {
            print("ENTERED PREPARE FOR SEGUE \(reviewID)")
            commentVC.delegate = self
            commentVC.reviewID = reviewID
            commentVC.userName = self.profileName.text ?? ""
            print("ENTERED PREPARE FOR SEGUE PASSED \(commentVC.reviewID)")

            commentVC.modalPresentationStyle = .overCurrentContext
            self.definesPresentationContext = true
        }
    }
    
   
    //function that segue to the comments tableview ViewController when the comment button is clicked
    func didTapCommentButton(reviewID: String) {
        print("CAME IN DID TAP SEGUE")
        performSegue(withIdentifier: "userCommentSegue", sender: reviewID)
    }
    
    // Function to change the edited data from UserProfile to MainUserProfileVC
    func populateUserInfoToProfileView(info: UserManager) {
        print("WENT IN FUNCTION SEGUE IN MAIN PROFILE")
        self.userProfileUsername.text = info.u_username
        self.profileName.text = info.u_name
        self.userProfileImg.image = info.u_img.image
        downloadImage(self.userProfileImg)
    }
    
    //function that fetchs all the users reviews and places them into our table View and our
    //array of reviews
    func fetchUserReviews() {
           //get the user that is currently logged in
           if let userID = self.userID {
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
           } else {
               print("No user is logged in")
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
               self.userReviewsTableView.reloadData()
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
 

    // this function populates the array of reviews that users have so far from firestore fill
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userReviews.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userReview = userReviews[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath) as! MainProfileTableViewCell
            if (userReviews.count > 0){
                cell.delegate = self
                cell.likeCount = userReview.numLikes ?? 0
                cell.reviewID = userReviewIDs[indexPath.row]
                
                cell.cafeName.text = userReview.coffeeShopName
                cell.cafeAdrr.text = userReview.address
                let cafeRanks = userReview.rating
                //populate the beans given the ranking
                let beans = [cell.bean11, cell.bean2, cell.bean3, cell.bean4, cell.bean5]
                for (index, bean) in beans.enumerated() {
                    bean?.image = cafeRanks > index ? UIImage(named: "filled_bean.png") : nil
                }

                cell.userComment.text = userReview.comment
                globLoadReviewImage(reviewId: userReviewIDs[indexPath.row]){images in
                    if let images = images, !images.isEmpty {
                        cell.drinkImg.image = images.first ?? UIImage(named: "beantherelog")// Show first image
                    }
                }
                makeImageOval(cell.drinkImg)
                //download image from firebase and display it
                downloadImage(cell.drinkImg)
            }
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReviewID = userReviewIDs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath) as! MainProfileTableViewCell
        if (userReviews.count > 0){
            
        }
    }
        
        
    }

