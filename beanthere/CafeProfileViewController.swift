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
        
        if let rating = reviewData["rating"] as? Int {
                // Set up the rating beans based on the rating
                for i in 0..<5 {
                    let imageView = cell.beanImageViews[i] // Assuming you have an array of UIImageViews in the cell
                    if i < rating {
                        imageView.image = UIImage(named: "filled_bean.png") // Set filled bean for rated beans
                    } else {
                        imageView.image = nil // Hide empty beans
                    }
                }
            }

        let tags = reviewData["tags"] as? [String] ?? []
        cell.tagOne.text = tags.indices.contains(0) ? tags[0] : ""
        cell.tagTwo.text = tags.indices.contains(1) ? tags[1] : ""

        if let fullName = userData?["fullName"] as? String, !fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            cell.userName.text = fullName
        } else {
            cell.userName.text = "Unknown User"
        }

        loadProfileImage(userId: reviewData["userID"] as! String) { image in
            DispatchQueue.main.async {
                cell.userProfilePicture.image = image

                // Ensure the image view is square before applying corner radius
                let sideLength = min(cell.userProfilePicture.frame.width, cell.userProfilePicture.frame.height)
                cell.userProfilePicture.layer.cornerRadius = sideLength / 2
                cell.userProfilePicture.clipsToBounds = true
            }
        }

        if let reviewId = reviewData["reviewId"] as? String {
            loadReviewImage(reviewId: reviewId) { images in
                DispatchQueue.main.async {
                    if let images = images, !images.isEmpty {
                        cell.imageOne.image = images[0] // Show first image

                        if images.count > 1 {
                            cell.imageTwo.image = images[1] // Show second image if available
                        }
                    }
                }
            }
        }
        
        cell.tagOne.adjustsFontSizeToFitWidth = true
        cell.tagOne.minimumScaleFactor = 0.8
        cell.tagOne.sizeToFit()

        cell.tagTwo.adjustsFontSizeToFitWidth = true
        cell.tagTwo.minimumScaleFactor = 0.8
        cell.tagTwo.sizeToFit()

        return cell
    }


    func loadProfileImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        print("loadProfileImage called for userId: \(userId)") // Debugging
        let storageRef = Storage.storage().reference().child("images/\(userId)file.png")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting profile image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let url = url {
                print("Profile image URL: \(url)") // Debugging
                self.downloadImage(from: url, completion: completion)
            }
        }
    }

    func loadReviewImage(reviewId: String, completion: @escaping ([UIImage]?) -> Void) {
        let storageRef = Storage.storage().reference().child("review_images/\(reviewId)/")

        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing images for review \(reviewId): \(error.localizedDescription)")
                completion(nil)
                return
            }

            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []

            for item in result!.items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let error = error {
                        print("Error getting image URL for \(item.name): \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }

                    if let url = url {
                        self.downloadImage(from: url) { image in
                            if let image = image {
                                images.append(image)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(images.isEmpty ? nil : images)
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
