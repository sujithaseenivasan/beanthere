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
    var reviews: [(reviewData: [String: Any], userData: [String: Any]?)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // from firebase download the image and make it round
        downloadImage(self.userProfileImg)
        makeImageOval(self.userProfileImg)
        
        userReviewsTableView.delegate = self
        userReviewsTableView.dataSource = self
        userReviewsTableView.rowHeight = 150
        //Default of timerTable
        userReviewsTableView.register(UITableViewCell.self, forCellReuseIdentifier: valCellIndetifier)
        
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        var profileUID = UserManager.shared.u_userID
        self.userID = profileUID
        
        // search in firebase if you find the user populate the users information in the swift fields
        let userField = Firestore.firestore().collection("reviews").document(profileUID)
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
            //put all the information of currently loaded data in the table
            //self.fetchUserData();
        }
    }
    
    //overwrite do the connection  between the 2 screens and the main screen
    override func prepare( for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == userSettingsSegueIdentifier,
           let userProfileVC = segue.destination as? UserProfileVC{
            userProfileVC.delegate =  self
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
    
    
    func fetchUserData() {
        guard let profileUID = self.userID else {
            print("Error: cafeId is nil in CafeProfileViewController")
            return
        }

        print("Fetching data for userID: \(profileUID)") // Debugging

        db.collection("users").document(profileUID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }

            if let document, document.exists, let data = document.data() {
                if let reviewIds = data["reviews"] as? [String] {
                    self.fetchReviews(reviewIds: reviewIds)
                }
            } else {
                print("Document does not exist.")
            }
        }
    }
    
    func fetchReviews(reviewIds: [String]) {
        let reviewCollection = db.collection("reviews")
        let userCollection = db.collection("users")

        var fetchedReviews: [(reviewData: [String: Any], userData: [String: Any]?)] = []

        let dispatchGroup = DispatchGroup()

        for reviewId in reviewIds {
            dispatchGroup.enter()
            
            reviewCollection.document(reviewId).getDocument { (reviewDoc, error) in
                if let error = error {
                    print("Error fetching review: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                if let reviewDoc, reviewDoc.exists, var reviewData = reviewDoc.data() {
                    let userId = reviewData["userID"] as? String ?? ""
                    
                    reviewData["reviewId"] = reviewDoc.documentID

                    dispatchGroup.enter()
                    userCollection.document(userId).getDocument { (userDoc, error) in
                        defer { dispatchGroup.leave() }
                        
                        if let error = error {
                            print("Error fetching user: \(error.localizedDescription)")
                            return
                        }

                        var userData = userDoc?.data() ?? [:]
                        
                        // Combine firstName and lastName
                        let firstName = userData["firstName"] as? String ?? ""
                        let lastName = userData["lastName"] as? String ?? ""
                        userData["fullName"] = firstName + " " + lastName
                        
                        fetchedReviews.append((reviewData, userData))
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.reviews = fetchedReviews
            //self.userReviewsTableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath as IndexPath)
        return cell
    }

}
