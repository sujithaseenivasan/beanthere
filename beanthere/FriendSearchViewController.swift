//
//  FriendSearchViewController.swift
//  beanthere
//
//  Created by Eshi Kohli on 4/9/25.
//

import UIKit
import FirebaseFirestore

let friendSearchCellIdentifier = "SearchFriendCell"

struct User {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
}

class FriendSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var friendSearchTableView: UITableView!
    
    @IBOutlet weak var searchFriends: UISearchBar!
    
    let db = Firestore.firestore()
    
    var initialSearchText: String?
    
    var allResults: [User] = []
    var filteredResults: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchFriends.text = initialSearchText
        searchFriends.delegate = self
        friendSearchTableView.delegate = self
        friendSearchTableView.dataSource = self
        
        
        friendSearchTableView.reloadData()
        
        loadUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchFriends.becomeFirstResponder()
        
        loadUsers()
        
        friendSearchTableView.reloadData()
        
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func loadUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading users: \(error)")
                return
            }
            guard let snapshot = snapshot else { return }
            self.allResults.removeAll()
            for document in snapshot.documents {
                let data = document.data()
                let firstName = data["firstName"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                var username = data["username"] as? String ?? ""
                // If the username is empty, use firstName+lastName (without spaces).
                if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    username = "@" + firstName + lastName
                }
                let user = User(id: document.documentID, firstName: firstName, lastName: lastName, username: username)
                self.allResults.append(user)
            }

            self.filteredResults = self.allResults
            DispatchQueue.main.async {
                self.friendSearchTableView.reloadData()
            }
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredResults = allResults
        } else {
            let lowerQuery = searchText.lowercased()
            filteredResults = allResults.filter { user in
                let fullName = "\(user.firstName) \(user.lastName)".lowercased()
                let usernameLower = user.username.lowercased()
                return fullName.contains(lowerQuery) || usernameLower.contains(lowerQuery)
            }
        }
        friendSearchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendSearchCellIdentifier, for: indexPath) as! FriendSearchTableViewCell
        cell.friendSearchName.font = UIFont(name: "Manjari-Bold", size: 18)
        cell.friendSearchUsername.font = UIFont(name: "Manjari-Regular", size: 14)
        let searchedUser = filteredResults[indexPath.row]
        
        cell.friendSearchName.text = "\(searchedUser.firstName) \(searchedUser.lastName)"
          cell.friendSearchUsername.text = searchedUser.username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredResults[indexPath.row]
        performSegue(withIdentifier: "SearchFriendProfileSegue", sender: selectedUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchFriendProfileSegue",
           let profileVC = segue.destination as? FriendProfileVC,
           let user = sender as? User {
            profileVC.delegate = self
            profileVC.friendID = user.id
        }
    }
}
