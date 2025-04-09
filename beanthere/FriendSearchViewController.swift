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

class FriendSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendSearchCellIdentifier, for: indexPath) as! FriendSearchTableViewCell
        
        return cell
    }
}
