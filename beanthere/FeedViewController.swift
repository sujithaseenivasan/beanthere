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

class FeedViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var hasPerformedSegue = false
    
    let db = Firestore.firestore()
    var friendIDs: [String] = []
    var reviews: [[String: Any]] = []
    
    var friendReviewData: [(reviewData: [String: Any], userData: [String: Any]?)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.rowHeight = 405
        fetchFriendReviews()
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendReviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedReviewTableViewCell", for: indexPath) as! FeedReviewTableViewCell

        let review = friendReviewData[indexPath.row].reviewData
        let user = friendReviewData[indexPath.row].userData

        // Comment
        cell.notesLabel.text = review["comment"] as? String ?? "No Comment"

        // User name
        cell.titleText.text = user?["fullName"] as? String ?? "Unknown"

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
                    if let images = images {
                        if images.indices.contains(0) { cell.imageOne.image = images[0] }
                        if images.indices.contains(1) { cell.imageTwo.image = images[1] }
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
                    
                    group.enter()
                    self.db.collection("users").document(userId).getDocument { userDoc, _ in
                        var user = userDoc?.data() ?? [:]
                        let first = user["firstName"] as? String ?? ""
                        let last = user["lastName"] as? String ?? ""
                        user["fullName"] = "\(first) \(last)"
                        dataTuples.append((review, user))
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.friendReviewData = dataTuples
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
        let ref = Storage.storage().reference().child("review_images/\(reviewId)/")
        ref.listAll { result, error in
            guard error == nil, let items = result?.items else {
                completion(nil)
                return
            }

            var images: [UIImage] = []
            let group = DispatchGroup()

            for item in items {
                group.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        self.downloadImage(from: url) { img in
                            if let img = img { images.append(img) }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                completion(images)
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
