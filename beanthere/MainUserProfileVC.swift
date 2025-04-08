//
//  MainUserProfileVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/2/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage


class MainUserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PassUserInfoToProfileView{
    
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var userProfileUsername: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    
    @IBOutlet weak var followingsNum: UILabel!
    
    @IBOutlet weak var userReviewsTableView: UITableView!
    //firestore instance
    let db = Firestore.firestore()
    var userID : String?
    let valCellIndetifier = "valCellID"
    let addReviewSegueIdentifier = "addReviewSegue"
    let userSettingsSegueIdentifier = "userSettingSegue"
    // Fake review data
    var userReviews:[Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // from firebase download the image and make it round
        downloadImage(self.userProfileImg)
        makeImageOval(self.userProfileImg)
        
        userReviewsTableView.delegate = self
        userReviewsTableView.dataSource = self
        //userReviewsTableView.rowHeight = 150
        //Default of timerTable
        userReviewsTableView.register(MainProfileTableViewCell.self, forCellReuseIdentifier: valCellIndetifier)
        
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        let profileUID = UserManager.shared.u_userID
        self.userID = profileUID
        
        // search in firebase if you find the user populate the users information in the swift fields
        let userField = Firestore.firestore().collection("users").document(profileUID)
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
            self.userProfileUsername.text = data?["username"] as? String ?? " "
            
            self.profileName.text = data?["firstName"] as? String ?? " "
            
            let reviewIDs: [String] = data?["reviews"] as? [String] ?? []
            //put all the information of currently loaded data in the array of reviews
            self.populateUserReviews( reviewIDs: reviewIDs)
            //reload and update any new info
            self.userReviewsTableView.reloadData()
            
        }
    }
    
    //overwrite do the connection  between the 2 screens and the main screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == userSettingsSegueIdentifier,
           let userProfileVC = segue.destination as? UserProfileVC {
            userProfileVC.delegate = self
        }
        
        if segue.identifier == "wantToTrySegue",
           let destination = segue.destination as? BrewTabsViewController {
            destination.defaultTabIndex = 1 // index 1 = "want to try"
        }
    }
    
    // Function to change the edited data from UserProfile to MainUserProfileVC
    func populateUserInfoToProfileView(info: UserManager) {
        print("WENT IN FUNCTION SEGUE IN MAIN PROFILE")
        self.userProfileUsername.text = info.u_username
        self.profileName.text = info.u_name
        self.userProfileImg.image = info.u_img.image
        downloadImage(self.userProfileImg)
    }
    
    // this function populates the array of reviews that users have so far from firestore fill
    func populateUserReviews( reviewIDs: [String]){
        let db = Firestore.firestore()
        let group = DispatchGroup() //Allow async actions to happen
        
        //forloop to populate each review that the user wrote
        for reviewID in reviewIDs{
            group.enter()
            let userReview = Firestore.firestore().collection("reviews").document(reviewID)
            userReview.getDocument { (docSnap, error) in
                //if user have an error guard it
                if let error = error {
                    print("Error fetching user review data: \(error.localizedDescription)")
                    return
                }
                guard let document = docSnap, document.exists else {
                    print("User reviews does not exist")
                    return
                }
                
                // Retrieve the fields from the Firestore document
                let data = document.data()!
                // Parse Firestore document into Review struct
                guard let cafeID = data["coffeeShopID"] as? String else {
                    print("CoffeShopID does not exist")
                    return
                }
                let comment = data["comment"] as? String ?? ""
                let rating = data["rating"] as? Int ?? 0
                let tags = data["tags"] as? [String] ?? []
                
                //now retrieve the data using the cafeID to get the cafe adress and name
                let cafeInfo = Firestore.firestore().collection("coffeeShops").document(cafeID)
                cafeInfo.getDocument { (docSnap, error) in
                    defer { group.leave() }
                    
                    let cafeData = docSnap!.data()!
                    let cafeName = cafeData["name"] as? String
                    let address = cafeData["address"] as? String
                    
                    //populate all the data we collected as a review and then add the review in the array
                    let review = Review(
                        coffeeShopID: cafeID,
                        coffeeShopName: cafeName,
                        address: address,
                        comment: comment,
                        rating: rating,
                        tags: tags,
                        timestamp:(data["timestamp"] as! Timestamp).dateValue()
                    )
                    
                    self.userReviews.append(review)
                    
                }
              }
            }
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userReviews.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var userReview = userReviews[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath) as! MainProfileTableViewCell
//            cell.cafeName.text = userReview.coffeeShopName ?? "Unknown cafe"
//            cell.cafeAdrr.text = userReview.address ?? "Unknown address"
//            cell.cafeRank.text = "\(userReview.rating)"
//            cell.cafeTag.text = userReview.tags.joined(separator: " ")
//            cell.comment.text = userReview.comment
            return cell
        }
        
    }

