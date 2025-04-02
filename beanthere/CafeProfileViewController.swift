//  CafeProfileViewController.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 3/9/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CafeProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagLabel3: UILabel!
    @IBOutlet weak var tagLabel2: UILabel!
    @IBOutlet weak var tagLabel1: UILabel!
    @IBOutlet weak var tagLabel4: UILabel!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    //firestore instance
    let db = Firestore.firestore()
    var cafeId: String?
    
    let tableCellIdentifier = "ReviewTableViewCell"
    let addReviewSegueIdentifier = "addReviewSegue"
    
    // Fake review data
    var reviews: [(reviewData: [String: Any], userData: [String: Any]?)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //adjust font size to fit into label
        cafeNameLabel.adjustsFontSizeToFitWidth = true
        cafeNameLabel.minimumScaleFactor = 0.5
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.5
        
        // allow description to go to multiple lines
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        makeLabelOval(tagLabel1)
        makeLabelOval(tagLabel2)
        makeLabelOval(tagLabel3)
        makeLabelOval(tagLabel4)
        
        // make image fill the UIImageView space
        cafeImage.contentMode = .scaleAspectFill
        cafeImage.clipsToBounds = true
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        reviewsTableView.rowHeight = 150
        
        fetchCafeData()
    }
    
    func fetchCafeData() {
        guard let cafeId = cafeId else {
            print("Error: cafeId is nil in CafeProfileViewController")
            return
        }

        print("Fetching data for cafeId: \(cafeId)") // Debugging

        db.collection("coffeeShops").document(cafeId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }

            if let document, document.exists, let data = document.data() {
                self.cafeNameLabel.text = data["name"] as? String ?? "No Name"
                self.addressLabel.text = data["address"] as? String ?? "No address"
                self.descriptionLabel.text = data["description"] as? String ?? "No description"

                if let imageUrl = data["image_url"] as? String {
                    self.loadImage(from: imageUrl)
                }

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

                if let reviewDoc, reviewDoc.exists, let reviewData = reviewDoc.data() {
                    let userId = reviewData["userID"] as? String ?? ""

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
            self.reviewsTableView.reloadData()
        }
    }



    
    //load image function
    func loadImage(from urlString: String) {
        //ensure URL is valid
        guard let url = URL(string: urlString) else { return }
        //try to download image data
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                //update the UI
                DispatchQueue.main.async {
                    self.cafeImage.image = image
                }
            }
        }
    }
    
    func loadReviewImage(reviewId: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference().child("review_images/\(reviewId)")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting review image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let url = url {
                self.downloadImage(from: url, completion: completion)
            }
        }
    }
    
    // helper function to make labels oval
    func makeLabelOval(_ label: UILabel) {
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addReviewSegueIdentifier {
            if let destinationVC = segue.destination as? AddReviewViewController {
                destinationVC.cafeId = self.cafeId
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! ReviewTableViewCell

        let reviewData = reviews[indexPath.row].reviewData
        let userData = reviews[indexPath.row].userData

        cell.reviewNotes.text = reviewData["comment"] as? String ?? "No Review"

        let tags = reviewData["tags"] as? [String] ?? []
        cell.tagOne.text = tags.indices.contains(0) ? tags[0] : ""
        cell.tagTwo.text = tags.indices.contains(1) ? tags[1] : ""

        if let fullName = userData?["fullName"] as? String, !fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            cell.userName.text = fullName
        } else {
            cell.userName.text = "Unknown User"
        }

        if let profilePicUrl = userData?["profilePicture"] as? String, !profilePicUrl.isEmpty {
            loadProfileImage(userId: profilePicUrl) { image in
                DispatchQueue.main.async {
                    cell.userProfilePicture.image = image
                    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.height / 2
                    cell.userProfilePicture.clipsToBounds = true
                }
            }
        }
        
        if let reviewId = reviewData["reviewId"] as? String {
            loadReviewImage(reviewId: reviewId) { image in
                DispatchQueue.main.async {
                    cell.imageOne.image = image
                }
            }
        }

        return cell
    }


    func loadProfileImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference().child("images/\(userId)")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting profile image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let url = url {
                self.downloadImage(from: url, completion: completion)
            }
        }
    }

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }
    }

    
}
