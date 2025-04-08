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
            
            // Compute overall cafe rating
            let totalRating = fetchedReviews.compactMap { $0.reviewData["rating"] as? Int }.reduce(0, +)
            let reviewCount = fetchedReviews.count
            let averageRating = reviewCount > 0 ? Double(totalRating) / Double(reviewCount) : 0.0
            self.updateCafeRatingDisplay(average: averageRating)

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
                imageView.image = UIImage(named: "filled_bean.png") // Add half bean later
            } else {
                imageView.image = nil
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
            "wantToTry": FieldValue.arrayUnion([cafeID])
        ]) { error in
            if let error = error {
                print("Failed to add cafe to wantToTry: \(error.localizedDescription)")
            } else {
                print("Cafe added to wantToTry")
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
        
        if let rating = reviewData["rating"] as? Int {
            let totalBeans = cell.beanImageViews.count
            for i in 0..<totalBeans {
                let imageView = cell.beanImageViews[i]
                if i >= totalBeans - rating {
                    imageView.image = UIImage(named: "filled_bean.png")
                } else {
                    imageView.image = nil
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

        loadProfileImage(userId: reviewData["userID"] as! String) { image in
            DispatchQueue.main.async {
                cell.userProfilePicture.image = image
                let sideLength = min(cell.userProfilePicture.frame.width, cell.userProfilePicture.frame.height)
                cell.userProfilePicture.layer.cornerRadius = sideLength / 2
                cell.userProfilePicture.clipsToBounds = true
            }
        }

        if let reviewId = reviewData["reviewId"] as? String {
            loadReviewImage(reviewId: reviewId) { images in
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


// MARK: - UILabel Padding Extension
extension UILabel {
    func padding(left: CGFloat, right: CGFloat) {
        if let currentConstraints = self.constraints.first(where: { $0.firstAttribute == .width }) {
            self.removeConstraint(currentConstraints)
        }
        let insets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
        let paddedWidth = self.intrinsicContentSize.width + insets.left + insets.right
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: paddedWidth).isActive = true
    }
}
struct TagStyler {
    static func configureTagLabels(_ labels: [UILabel], withTags tags: [String]) {
        let colors: [UIColor] = [
            UIColor(named: "TagColor1") ?? .red,
            UIColor(named: "TagColor2") ?? .blue,
            UIColor(named: "TagColor3") ?? .green,
            UIColor(named: "TagColor4") ?? .orange,
            UIColor(named: "TagColor5") ?? .purple
        ]
        
        if tags.isEmpty {
            for (index, label) in labels.enumerated() {
                if index == 0 {
                    label.text = "No tags yet"
                    label.isHidden = false
                    label.backgroundColor = .lightGray
                    label.textColor = .white
                    label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                    label.textAlignment = .center
                    label.layer.cornerRadius = 12
                    label.layer.masksToBounds = true
                    label.sizeToFit()
                    label.layoutIfNeeded()
                    label.setContentHuggingPriority(.required, for: .horizontal)
                    label.setContentCompressionResistancePriority(.required, for: .horizontal)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
                    label.padding(left: 12, right: 12)
                } else {
                    label.text = ""
                    label.isHidden = true
                }
            }
            return
        }

        for (index, label) in labels.enumerated() {
            if index < tags.count {
                label.text = tags[index]
                label.isHidden = false
                label.backgroundColor = colors[index % colors.count]
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                label.textAlignment = .center
                label.layer.cornerRadius = label.layer.frame.height > 0 ? label.layer.frame.height / 2 : 15
                label.layer.masksToBounds = true
                label.sizeToFit()
                label.layoutIfNeeded()
                label.setContentHuggingPriority(.required, for: .horizontal)
                label.setContentCompressionResistancePriority(.required, for: .horizontal)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
                label.padding(left: 12, right: 12)
            } else {
                label.text = ""
                label.isHidden = true
            }
        }
    }
}


