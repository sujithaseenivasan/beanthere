//
//  FeedViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/3/25.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            performSegue(withIdentifier: "coffeeSearchSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "coffeeSearchSegue",
           let searchVC = segue.destination as? CoffeeSearchViewController {
            searchVC.initialSearchText = searchBar.text
        }
    }

    
    @IBAction func logoutPressed(_sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign Out error")
        }
    }

}
