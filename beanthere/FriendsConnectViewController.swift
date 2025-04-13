//
//  FriendsConnectViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

let suggestFriendCellIdentifier = "SuggestedFriendCell"
let contactsFriendCellIdentifier = "ContactsFriendCell"

struct Friend {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
    var profilePicture: String?
}

class FriendsConnectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var suggestFriendsCollection: UICollectionView!
    
    @IBOutlet weak var contactsFriendsCollection: UICollectionView!
    
    
    @IBOutlet weak var noSuggestedFriendsLabel: UILabel!
    
    @IBOutlet weak var giveContactsAccess: UIButton!
    
    @IBOutlet weak var searchFriends: UISearchBar!
    private var hasPerformedSegue = false
    
    var suggestedFriends: [Friend] = []
    var selectedFriendId: String = ""
    var currUserFollowing: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestFriendsCollection.delegate = self
        suggestFriendsCollection.dataSource = self

        contactsFriendsCollection.delegate = self
        contactsFriendsCollection.dataSource = self
        
        searchFriends.delegate = self

        loadSuggestedFriends()
    }
    
    func searchBar(_ searchFriends: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty && !hasPerformedSegue {
            hasPerformedSegue = true
            performSegue(withIdentifier: "FriendSearch", sender: self)
            hasPerformedSegue = false
        }
    }
    
    func loadSuggestedFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        
        // get user document from firebase
        db.collection("users").document(currentUserId).getDocument { (document, error) in
            if let error = error {
                print("Error getting current user document: \(error)")
                return
            }
            guard let document = document, document.exists,
                  let data = document.data() else { return }
            
            if let following = data["friendsList"] as? [String] {
                self.currUserFollowing = following
                
                // if user isn't following anyong, then hide collection
                if following.isEmpty {
                    self.suggestFriendsCollection.isHidden = true
                    self.noSuggestedFriendsLabel.isHidden = false
                } else {
                    self.suggestFriendsCollection.isHidden = false
                    self.noSuggestedFriendsLabel.isHidden = true
                    
                    // a set to collect unique friend ids from followers of all followed users
                    var suggestionSet = Set<String>()
                    
                    let dispatchGroup = DispatchGroup()
                    
                    // iterate over each followed user to retrieve their followers
                    for followId in following {
                        print(followId)
                        dispatchGroup.enter()
                        db.collection("users").document(followId).getDocument { (followDoc, error) in
                            if let followDoc = followDoc,
                               followDoc.exists,
                               let followData = followDoc.data(),
                               let followers = followData["friendsList"] as? [String] {
                                for followerId in followers {
                                    print(followerId)
                                    // exclude current user and those the current user is already following
                                    if followerId != currentUserId && !self.currUserFollowing.contains(followerId) {
                                        suggestionSet.insert(followerId)
                                    }
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    // retrieve each suggested friend’s details
                    dispatchGroup.notify(queue: .main) {
                        let friendDispatchGroup = DispatchGroup()
                        
                        for friendId in suggestionSet {
                            friendDispatchGroup.enter()
                            db.collection("users").document(friendId).getDocument { (friendDoc, error) in
                                if let friendDoc = friendDoc,
                                   friendDoc.exists,
                                   let friendData = friendDoc.data() {
                                    
                                    let firstName = friendData["firstName"] as? String ?? ""
                                    let lastName = friendData["lastName"] as? String ?? ""
                                    var username = friendData["username"] as? String ?? ""
                                    
                                    // if the username is empty, combine first and last name
                                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        username = firstName + lastName
                                    }
                                    
                                    let profilePicture = friendData["profilePicture"] as? String
                                    
                                    let friend = Friend(id: friendId,
                                                        firstName: firstName,
                                                        lastName: lastName,
                                                        username: username,
                                                        profilePicture: profilePicture)
                                    self.suggestedFriends.append(friend)
                                }
                                friendDispatchGroup.leave()
                            }
                        }
                        
                        friendDispatchGroup.notify(queue: .main) {
                            self.suggestFriendsCollection.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == suggestFriendsCollection {
                return suggestedFriends.count
            } else if collectionView == contactsFriendsCollection {
                // TODO: return logic for contacts friends here
                return 0
            }
            return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == suggestFriendsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: suggestFriendCellIdentifier, for: indexPath) as! FriendSuggestionCollectionViewCell
            
            let friend = suggestedFriends[indexPath.row]
            cell.suggestedFriendName.text = "\(friend.firstName) \(friend.lastName)"
            cell.suggestedFriendUsername.text = friend.username
            cell.friendId = friend.id
            // load profile picture asynchronously
            if let profilePictureUrlString = friend.profilePicture,
               let url = URL(string: profilePictureUrlString) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, error == nil {
                        DispatchQueue.main.async {
                            cell.suggestedFriendImage.image = UIImage(data: data)
                        }
                    }
                }.resume()
            } else {
                cell.suggestedFriendImage.image = UIImage(named: "filled_bean")
            }
            
            return cell
        } else if collectionView == contactsFriendsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contactsFriendCellIdentifier, for: indexPath)
            // TODO: add stuff for contacts cell
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == suggestFriendsCollection {
            let selectedFriend = suggestedFriends[indexPath.row]
            selectedFriendId = selectedFriend.id
            performSegue(withIdentifier: "suggGoToFriendProfID", sender: self)
        } else if collectionView == contactsFriendsCollection {
            // TODO: handling a selection in contacts collection, set selectedFriendId the same way as above
            // performSegue(withIdentifier: "contactGoToFriendProfID", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewRequests",
           let nextVC = segue.destination as? FriendRequestsViewController {
            nextVC.delegate = self
        } else if segue.identifier == "suggGoToFriendProfID" || segue.identifier == "contactGoToFriendProfID" , let nextVC = segue.destination as? FriendProfileVC {
            nextVC.delegate = self
            // nextVC.friendID = testForFriendID.text ?? ""
            nextVC.friendID = selectedFriendId
            navigationController?.pushViewController(nextVC, animated: true)
        } else if segue.identifier == "FriendSearch", let nextVC = segue.destination as? FriendSearchViewController {
            nextVC.initialSearchText = searchFriends.text
        }
    }
}
