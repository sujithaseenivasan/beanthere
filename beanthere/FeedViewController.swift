//
//  FeedViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FeedViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FeedReviewCellDelegate {
    

    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var hasPerformedSegue = false
    
    let db = Firestore.firestore()
    var friendIDs: [String] = []
    var reviews: [[String: Any]] = []
    var likedReviewIDs: Set<String> = []

    
    var friendReviewData: [(reviewData: [String: Any], userData: [String: Any]?)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.rowHeight = 300
        
        view.addSubview(noFriendsLabel)
            NSLayoutConstraint.activate([
                noFriendsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noFriendsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                noFriendsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
                noFriendsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
            ])

        fetchLikedReviews()
        feedTableView.reloadData()
        print("is this being called")
        fetchFriendReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLikedReviews()
        fetchFriendReviews()
        feedTableView.reloadData()
    }
    
    
    private let noFriendsLabel: UILabel = {
        let label = UILabel()
        label.text = "No friend activity yet!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         if !searchText.isEmpty && !hasPerformedSegue {
             hasPerformedSegue = true
             performSegue(withIdentifier: "coffeeSearchSegue", sender: self)
             hasPerformedSegue = false
         }
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "coffeeSearchSegue",
           let searchVC = segue.destination as? CoffeeSearchViewController {
            searchVC.initialSearchText = searchBar.text
        }
    }
    
    func didTapLikeButton(for reviewId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let reviewRef = db.collection("reviews").document(reviewId)
        let userRef = db.collection("users").document(currentUserId)

        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var likedReviews = data["likedReviews"] as? [String] ?? []
            let hasLiked = likedReviews.contains(reviewId)
            let likeChange = hasLiked ? -1 : 1

            if hasLiked {
                likedReviews.removeAll { $0 == reviewId }
                self.likedReviewIDs.remove(reviewId)
            } else {
                likedReviews.append(reviewId)
                self.likedReviewIDs.insert(reviewId)
            }

            userRef.updateData(["likedReviews": likedReviews])
            reviewRef.updateData(["friendsLikes": FieldValue.increment(Int64(likeChange))]) { error in
                if let error = error {
                    print("Failed to update likes: \(error.localizedDescription)")
                    return
                }

                if let index = self.friendReviewData.firstIndex(where: { $0.reviewData["reviewId"] as? String == reviewId }) {
                    var review = self.friendReviewData[index].reviewData
                    let currentLikes = (review["friendsLikes"] as? Int ?? 0) + likeChange
                    review["friendsLikes"] = max(0, currentLikes) // avoid negative values
                    self.friendReviewData[index].reviewData = review

                    DispatchQueue.main.async {
                        self.feedTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendReviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedReviewTableViewCell", for: indexPath) as! FeedReviewTableViewCell
        

        let review = friendReviewData[indexPath.row].reviewData
        let user = friendReviewData[indexPath.row].userData

        // Comment
        cell.notesLabel.text = review["comment"] as? String ?? "No Comment"
        
        cell.delegate = self
        cell.reviewId = review["reviewId"] as? String
        
        if let likes = review["friendsLikes"] as? Int {
            cell.likeCountLabel.text = "\(likes) Likes"
        } else {
            cell.likeCountLabel.text = "0 Likes"
        }

        if let reviewId = review["reviewId"] as? String {
            let isLiked = likedReviewIDs.contains(reviewId)
            let heartSymbol = isLiked ? "heart.fill" : "heart"
            cell.likeButton.setImage(UIImage(systemName: heartSymbol), for: .normal)
        }


        // User name
        let name = user?["fullName"] as? String ?? "Unknown"
        let cafeName = user?["coffeeShopName"] as? String ?? ""
        cell.titleText.text = "\(name) rated \(cafeName)"
        
        cell.locationLabel.text = cafeName

        // Date
        if let timestamp = review["timestamp"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            cell.dateLabel.text = formatter.string(from: timestamp.dateValue())
        }

        // Tags
        if let tags = review["tags"] as? [String] {
            TagStyler.configureTagLabels(cell.reviewTagLabels, withTags: Array(tags.prefix(4)))
        }

        // Beans
        if let rating = review["rating"] as? Int {
            let totalBeans = cell.cafeBeanImageViews.count
            for i in 0..<totalBeans {
                let imageView = cell.cafeBeanImageViews[i]
                imageView.image = i < rating ? UIImage(named: "filled_bean.png") : nil
            }
        }

        // Profile Picture
        if let userID = review["userID"] as? String {
            loadProfileImage(userId: userID) { image in
                DispatchQueue.main.async {
                    cell.profilePicture.image = image
                    let radius = min(cell.profilePicture.frame.width, cell.profilePicture.frame.height) / 2
                    cell.profilePicture.layer.cornerRadius = radius
                    cell.profilePicture.clipsToBounds = true
                }
            }
        }

        // Review Images
        if let reviewId = review["reviewId"] as? String {
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

    
    func formatTimestamp(_ timestamp: Any?) -> String {
        if let ts = timestamp as? Timestamp {
            let date = ts.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }
    
    func fetchFriendReviews() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        print(currentUserID + " being fetched")
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.friendIDs = document.get("friendsList") as? [String] ?? []
                DispatchQueue.main.async {
                    if self.friendIDs.isEmpty {
                        self.noFriendsLabel.isHidden = false
                        self.feedTableView.isHidden = true
                    } else {
                        self.noFriendsLabel.isHidden = true
                        self.feedTableView.isHidden = false
                        self.fetchReviewsFromFriends()
                    }
                }
                self.fetchReviewsFromFriends()
            } else {
                print("User document does not exist")
            }
        }
    }
    
    func fetchReviewsFromFriends() {
        guard !friendIDs.isEmpty else { return }
        
        db.collection("reviews")
            .whereField("userID", in: friendIDs)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "No reviews found.")")
                    return
                }
                
                let reviewDocs = documents
                var dataTuples: [(reviewData: [String: Any], userData: [String: Any]?)] = []
                let group = DispatchGroup()
                
                for doc in reviewDocs {
                    var review = doc.data()
                    review["reviewId"] = doc.documentID
                    let userId = review["userID"] as? String ?? ""
                    let coffeeShopId = review["coffeeShopID"] as? String ?? ""
                    
                    group.enter()
                    self.db.collection("users").document(userId).getDocument { userDoc, _ in
                        var user = userDoc?.data() ?? [:]
                        let first = user["firstName"] as? String ?? ""
                        let last = user["lastName"] as? String ?? ""
                        user["fullName"] = "\(first) \(last)"
                        
            
                        group.enter()
                        self.db.collection("coffeeShops").document(coffeeShopId).getDocument { cafeDoc, _ in
                            let cafeName = cafeDoc?.data()?["name"] as? String ?? ""
                            user["coffeeShopName"] = cafeName
                            dataTuples.append((review, user))
                            group.leave()
                        }
                        
                        group.leave()
                    }
                }

                
                group.notify(queue: .main) {
                    self.friendReviewData = dataTuples
                    self.feedTableView.reloadData()
                }
            }
    }
    
    func fetchLikedReviews() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(currentUserId).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error getting liked reviews")
                return
            }
            self.likedReviewIDs = Set(data["likedReviews"] as? [String] ?? [])
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
    }



    //Helpers
    func loadProfileImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference().child("images/\(userId)file.png")
        ref.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(nil)
                return
            }
            self.downloadImage(from: url, completion: completion)
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
                DispatchQueue.main.async { completion(image) }
            } else {
                completion(nil)
            }
        }
    }
}
