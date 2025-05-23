//
//  FriendsConnectViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/7/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Contacts

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
    
    @IBOutlet weak var viewRequestsLabel: UIButton!
    
    @IBOutlet weak var suggestedForYouLabel: UILabel!
    
    
    @IBOutlet weak var fromYourContactsLabel: UILabel!
    @IBOutlet weak var suggestFriendsCollection: UICollectionView!
    
    @IBOutlet weak var contactsFriendsCollection: UICollectionView!
    
    
    @IBOutlet weak var noSuggestedFriendsLabel: UILabel!
    
    @IBOutlet weak var giveContactsAccess: UIButton!
    
    @IBOutlet weak var searchFriends: UISearchBar!
    private var hasPerformedSegue = false
    
    var suggestedFriends: [Friend] = []
    var selectedFriendId: String = ""
    var currUserFollowing: [String] = []
    
    var contactsList: [CNContact] = []
    var contactsFriends: [Friend] = []
    
    private var currUserRequested: [String] = [] // ADDED FOR DEMO
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRequestsLabel.titleLabel?.font = UIFont(name: "Manjari-Bold", size: 20)
        suggestedForYouLabel.font = UIFont(name: "Manjari-Bold", size: 24)
        fromYourContactsLabel.font = UIFont(name: "Manjari-Bold", size: 24)
        
        suggestFriendsCollection.delegate = self
        suggestFriendsCollection.dataSource = self

        contactsFriendsCollection.delegate = self
        contactsFriendsCollection.dataSource = self
        
        searchFriends.delegate = self
        
        let contactsAuthStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if contactsAuthStatus == .authorized {
            giveContactsAccess.isHidden = true
            contactsFriendsCollection.isHidden = false
            
            print("CONTACTS AUTHORIZED!!!!!")
            
            fetchContactsAndLoadFriends()
            
        } else {
            giveContactsAccess.isHidden = false
            contactsFriendsCollection.isHidden = true
        }
        
//        loadSuggestedFriends()
        fetchCurrentUserRequests(firstLoad: true)
    }
    
    // ADDED FOR THE DEMO
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUserRequests()
    }
    
    private func fetchCurrentUserRequests(firstLoad: Bool = false) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snap, _ in
                if let data = snap?.data(),
                   let req = data["requested"] as? [String] {
                    self.currUserRequested = req
                } else {
                    self.currUserRequested = []
                }
                
                if firstLoad {
                    self.loadSuggestedFriends()
                    if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
                        self.loadContactsFriends()
                    }
                }
                
                self.suggestedFriends.removeAll { self.currUserRequested.contains($0.id) }
                self.contactsFriends.removeAll { self.currUserRequested.contains($0.id) }
                
                DispatchQueue.main.async {
                    self.suggestFriendsCollection.reloadData()
                    self.contactsFriendsCollection.reloadData()
                }
            }
    }
    
    // END ADDED FOR DEMO
    
    func searchBar(_ searchFriends: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty && !hasPerformedSegue {
            hasPerformedSegue = true
            performSegue(withIdentifier: "FriendSearch", sender: self)
            hasPerformedSegue = false
        }
    }
    
    func normalizePhoneNumber(_ number: String) -> String {
        let allowedCharacterSet = CharacterSet.decimalDigits
        let filteredCharacters = number.unicodeScalars.filter { allowedCharacterSet.contains($0) }
        return String(String.UnicodeScalarView(filteredCharacters))
    }
    
    func fetchContactsAndLoadFriends() {
        DispatchQueue.global(qos: .userInitiated).async {
            let contactsStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
            var fetchedContacts: [CNContact] = []
            
            do {
                try contactsStore.enumerateContacts(with: fetchRequest) { (contact, _) in
                    fetchedContacts.append(contact)
                }
                DispatchQueue.main.async {
                    self.contactsList = fetchedContacts
                    print("Fetched contacts: \(self.contactsList)")
                    self.loadContactsFriends()
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Contacts Error",
                        message: "Unable to fetch contacts.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    
    func loadContactsFriends() {
        print("IN LOAD CONTACTS METHOD")
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        
        var phoneNumbersSet = Set<String>()
        print(contactsList)
        for contact in contactsList {
            for phoneNumber in contact.phoneNumbers {
                let normalizedNumber = normalizePhoneNumber(phoneNumber.value.stringValue)
                phoneNumbersSet.insert(normalizedNumber)
            }
        }
        
        let phoneNumbersArr = Array(phoneNumbersSet)
        
        print("HERE IS PHONE NUMBER ARRAY")
        print(phoneNumbersArr)
        if phoneNumbersArr.isEmpty {
            return
        }
        
        db.collection("users").whereField("phoneNumber", in: phoneNumbersArr).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching contacts friends: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            
            self.contactsFriends.removeAll()
            
            for doc in documents {
                if doc.documentID == currentUserId {
                    continue
                }
                
                let data = doc.data()
                let firstName = data["firstName"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                var username = data["username"] as? String ?? ""
                if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    username = "@" + firstName + lastName
                }
                let profilePicture = data["profilePicture"] as? String
                let friend = Friend(id: doc.documentID,
                                    firstName: firstName,
                                    lastName: lastName,
                                    username: username,
                                    profilePicture: profilePicture)
                self.contactsFriends.append(friend)
            }
            
            self.contactsFriends.removeAll {
              self.currUserFollowing.contains($0.id) ||
              self.currUserRequested.contains($0.id)
            }
            
            DispatchQueue.main.async {
                self.contactsFriendsCollection.reloadData()
            }
        }
    }
    
    func loadSuggestedFriends() {
        self.suggestedFriends.removeAll()
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
                                        username = "@" + firstName + lastName
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
                            self.suggestedFriends.removeAll {
                                self.currUserFollowing.contains($0.id) || self.currUserRequested.contains($0.id)
                            }
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
                return contactsFriends.count
            }
            return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == suggestFriendsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: suggestFriendCellIdentifier, for: indexPath) as! FriendSuggestionCollectionViewCell
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            let friend = suggestedFriends[indexPath.row]
            cell.suggestedFriendName.text = "\(friend.firstName) \(friend.lastName)"
            cell.suggestedFriendName.font = UIFont(name: "Manjari-Regular", size: 16)
            cell.suggestedFriendUsername.text = friend.username
            cell.suggestedFriendUsername.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.suggestedFriendUsername.textColor = UIColor.black.withAlphaComponent(0.5)
//            cell.suggestedFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.friendId = friend.id
            // load profile picture asynchronously
//            if let profilePictureUrlString = friend.profilePicture,
//               let url = URL(string: profilePictureUrlString) {
//                URLSession.shared.dataTask(with: url) { data, response, error in
//                    if let data = data, error == nil {
//                        DispatchQueue.main.async {
//                            cell.suggestedFriendImage.image = UIImage(data: data)
////                            cell.suggestedFriendImage.contentMode = .scaleAspectFill
//                            cell.suggestedFriendImage.layer.cornerRadius = (cell.suggestedFriendImage.bounds.width / 2) + 3
//                            cell.suggestedFriendImage.clipsToBounds = true
//                            cell.suggestedFriendImage.layer.masksToBounds = true
//                        }
//                    }
//                }.resume()
//            } else {
//                cell.suggestedFriendImage.image = UIImage(named: "filled_bean")
////                cell.suggestedFriendImage.contentMode = .scaleAspectFill
//                cell.suggestedFriendImage.layer.cornerRadius = (cell.suggestedFriendImage.bounds.width / 2) + 3
//                cell.suggestedFriendImage.clipsToBounds = true
//                cell.suggestedFriendImage.layer.masksToBounds = true
//            }
            
            FirebaseUtil.loadProfileImage(userId: friend.id) { image in DispatchQueue.main.async {
                let img = image ?? UIImage(named: "filled_bean")
                cell.suggestedFriendImage.image = img
                cell.suggestedFriendImage.contentMode = .scaleAspectFill
                cell.suggestedFriendImage.layer.cornerRadius = (cell.suggestedFriendImage.bounds.width / 2) + 3
                cell.suggestedFriendImage.clipsToBounds = true
                }
            }
            
            // ADDED FOR DEMO
            let alreadySent = currUserRequested.contains(friend.id)
            cell.suggestedFriendFollowButton.setTitle(alreadySent ? "Sent" : "Follow", for: .normal)
            cell.suggestedFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.suggestedFriendFollowButton.isEnabled = !alreadySent
            // END ADDED FOR DEMO
            return cell
        } else if collectionView == contactsFriendsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contactsFriendCellIdentifier, for: indexPath) as! FriendContactsCollectionViewCell
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            let friend = contactsFriends[indexPath.row]
            cell.contactFriendName.text = "\(friend.firstName) \(friend.lastName)"
            cell.contactFriendName.font = UIFont(name: "Manjari-Regular", size: 16)
            cell.contactFriendUsername.text = friend.username
            cell.contactFriendUsername.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.contactFriendUsername.textColor = UIColor.black.withAlphaComponent(0.5)
//            cell.contactFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.friendId = friend.id
            // load profile picture asynchronously
//            if let profilePictureUrlString = friend.profilePicture,
//               let url = URL(string: profilePictureUrlString) {
//                URLSession.shared.dataTask(with: url) { data, response, error in
//                    if let data = data, error == nil {
//                        DispatchQueue.main.async {
//                            cell.contactFriendImage.image = UIImage(data: data)
////                            cell.contactFriendImage.contentMode = .scaleAspectFill
//                            cell.contactFriendImage.layer.cornerRadius = (cell.contactFriendImage.bounds.width / 2) + 3
//                            cell.contactFriendImage.clipsToBounds = true
//                            cell.contactFriendImage.layer.masksToBounds = true
//                        }
//                    }
//                }.resume()
//            } else {
//                cell.contactFriendImage.image = UIImage(named: "filled_bean")
////                cell.contactFriendImage.contentMode = .scaleAspectFill
//                cell.contactFriendImage.layer.cornerRadius = (cell.contactFriendImage.bounds.width / 2) + 3
//                cell.contactFriendImage.clipsToBounds = true
//                cell.contactFriendImage.layer.masksToBounds = true
//            }
            
            FirebaseUtil.loadProfileImage(userId: friend.id) { image in DispatchQueue.main.async {
                let img = image ?? UIImage(named: "filled_bean")
                cell.contactFriendImage.image = img
                cell.contactFriendImage.contentMode = .scaleAspectFill
                cell.contactFriendImage.layer.cornerRadius = (cell.contactFriendImage.bounds.width / 2) + 3
                cell.contactFriendImage.clipsToBounds = true
                }
            }
            
            // ADDED FOR DEMO
            let alreadySent = currUserRequested.contains(friend.id)
            cell.contactFriendFollowButton.setTitle(alreadySent ? "Sent" : "Follow", for: .normal)
            cell.contactFriendFollowButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 12)
            cell.contactFriendFollowButton.isEnabled = !alreadySent
         
//            // END ADDED FOR DEMO
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == suggestFriendsCollection {
            let selectedFriend = suggestedFriends[indexPath.row]
            selectedFriendId = selectedFriend.id
            performSegue(withIdentifier: "suggestedFriendsProfileSegue", sender: selectedFriendId)
        } else if collectionView == contactsFriendsCollection {
            // TODO: handling a selection in contacts collection, set selectedFriendId the same way as above
            let selectedFriend = contactsFriends[indexPath.row]
            selectedFriendId = selectedFriend.id
            performSegue(withIdentifier: "suggestedFriendsProfileSegue", sender: selectedFriendId)
        }
    }
    
    
    @IBAction func requestContactsAccess(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contactsStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)

            var fetchedContacts: [CNContact] = []

            do {
                try contactsStore.enumerateContacts(with: fetchRequest) { (contact, _) in
                    fetchedContacts.append(contact)
                }

                DispatchQueue.main.async {
                    self.contactsList = fetchedContacts
                    print(self.contactsList)
                    self.giveContactsAccess.isHidden = true
                    self.contactsFriendsCollection.isHidden = false
                    self.loadContactsFriends()
                    self.contactsFriendsCollection.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Access to contacts needed",
                        message: "Please click the button again",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewRequests",
           let nextVC = segue.destination as? FriendRequestsViewController {
            nextVC.delegate = self
        } else if segue.identifier == "suggestedFriendsProfileSegue", let nextVC = segue.destination as? FriendProfileVC, let user = sender as? String {
            nextVC.delegate = self
            // nextVC.friendID = testForFriendID.text ?? ""
            nextVC.friendID = user
//            navigationController?.pushViewController(nextVC, animated: true)
        } else if segue.identifier == "FriendSearch", let nextVC = segue.destination as? FriendSearchViewController {
            nextVC.initialSearchText = searchFriends.text
        }
    }
}
