//  CafeProfileViewController.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 3/9/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CafeProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var whatOtherBeanthereUsersSaidTextLabel: UILabel!
    
    @IBOutlet weak var cafeRatingStackView: UIStackView!
    
    @IBOutlet var cafeBeanImageViews: [UIImageView]!

    @IBOutlet var cafeTagLabels: [UILabel]!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    //firestore instance
    let db = Firestore.firestore()
    var cafeId: String?
    
    let tableCellIdentifier = "ReviewTableViewCell"
    let addReviewSegueIdentifier = "addReviewSegue"
    
    // Fake review data
    var reviews: [(reviewData: [String: Any], userData: [String: Any]?)] = []
    
    private let noReviewsLabel: UILabel = {
        let label = UILabel()
        label.text = "No reviews yet!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafeNameLabel.font = UIFont(name: "Lora-Bold", size: 32)
        addressLabel.font = UIFont(name: "Lora-SemiBold", size: 14)
        descriptionLabel.font = UIFont(name: "Lora-Medium", size: 14)
        whatOtherBeanthereUsersSaidTextLabel.font = UIFont(name: "Lora-Bold", size: 17.5)
        
        //adjust font size to fit into label
        cafeNameLabel.adjustsFontSizeToFitWidth = true
        cafeNameLabel.minimumScaleFactor = 0.5
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.5
        
        // allow description to go to multiple lines
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        // make image fill the UIImageView space
        cafeImage.contentMode = .scaleAspectFill
        cafeImage.clipsToBounds = true
        
        view.addSubview(noReviewsLabel)
        NSLayoutConstraint.activate([
            noReviewsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noReviewsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 175),
            noReviewsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            noReviewsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        
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
            
            // Compute overall cafe rating
            let totalRating = fetchedReviews.compactMap { $0.reviewData["rating"] as? Int }.reduce(0, +)
            let reviewCount = fetchedReviews.count
            let averageRating = reviewCount > 0 ? Double(totalRating) / Double(reviewCount) : 0.0
            self.updateCafeRatingDisplay(average: averageRating)
            
            if fetchedReviews.isEmpty {
                self.noReviewsLabel.isHidden = false
                self.reviewsTableView.isHidden = true
            } else {
                self.noReviewsLabel.isHidden = true
                self.reviewsTableView.isHidden = false
            }

            // Determine most popular cafe tags
            var tagFrequency: [String: Int] = [:]

            for (reviewData, _) in fetchedReviews {
                if let tags = reviewData["tags"] as? [String] {
                    for tag in tags {
                        tagFrequency[tag, default: 0] += 1
                    }
                }
            }

            let sortedTags = tagFrequency.sorted { $0.value > $1.value }
            let topTags = sortedTags.prefix(4).map { $0.key }
            self.view.layoutIfNeeded()
            TagStyler.configureTagLabels(self.cafeTagLabels, withTags: Array(topTags))



            self.reviewsTableView.reloadData()
        }
    }
    
    func updateCafeRatingDisplay(average: Double) {
        let totalBeans = cafeBeanImageViews.count
        for i in 0..<totalBeans {
            let imageView = cafeBeanImageViews[i]
            if Double(i + 1) <= average {
                imageView.image = UIImage(named: "filled_bean.png")
            } else if Double(i) < average {
                imageView.image = UIImage(named: "filled_bean.png")
            } else {
                imageView.image = UIImage(named: "unfilled_bean.png")
            }
        }
    }


    @IBAction func bookmarkBtnPressed(_ sender: Any) {
        //get the user that is currently logged in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        let cafeID = cafeId
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        // update the array, girestore will create the field if needed, and avoid duplicates
        userRef.updateData([
            "wantToTry": FieldValue.arrayUnion([cafeID ?? ""])
        ]) { error in
            if let error = error {
                print("Failed to add cafe to wantToTry: \(error.localizedDescription)")
            } else {
                print("Cafe added to wantToTry")
                let alert = UIAlertController(title: "Saved!", message: "Coffee shop saved to Brew Log.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
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
        
        if let rating = reviewData["rating"] as? Double {
            let totalBeans = cell.beanImageViews.count
            for i in 0..<totalBeans {
                let imageView = cell.beanImageViews[i]
                if Double(i + 1) <= rating {
                    imageView.image = UIImage(named: "filled_bean.png")
                } else if Double(i) < rating {
                    imageView.image = UIImage(named: "filled_bean.png")
                } else {
                    imageView.image = UIImage(named: "unfilled_bean.png")
                }
            }
        }


        let tags = reviewData["tags"] as? [String] ?? []

        // NEW: Use the shared tag label styling method
        TagStyler.configureTagLabels(cell.reviewTagLabels, withTags: tags)

        if let fullName = userData?["fullName"] as? String, !fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            cell.userName.text = fullName
        } else {
            cell.userName.text = "Unknown User"
        }

        FirebaseUtil.loadProfileImage(userId: reviewData["userID"] as! String) { image in
            DispatchQueue.main.async {
                cell.userProfilePicture.image = image
                let sideLength = min(cell.userProfilePicture.frame.width, cell.userProfilePicture.frame.height)
                cell.userProfilePicture.layer.cornerRadius = sideLength / 2
                cell.userProfilePicture.clipsToBounds = true
            }
        }

        if let reviewId = reviewData["reviewId"] as? String {
            FirebaseUtil.loadReviewImage(reviewId: reviewId) { images in
                DispatchQueue.main.async {
                    if let images = images, !images.isEmpty {
                        cell.imageOne.image = images[0]
                        if images.count > 1 {
                            cell.imageTwo.image = images[1]
                        }
                    }
                }
            }
        }

        return cell
    }
}


