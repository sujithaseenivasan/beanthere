//
//  FriendProfileVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/7/25.
//

import UIKit

class FriendProfileVC: UIViewController {
    
    @IBOutlet weak var friendImg: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var friendUserName: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    @IBOutlet weak var followingNum: UILabel!
    
    @IBOutlet weak var beenNum: UILabel!
    @IBOutlet weak var wantNum: UILabel!
    
    @IBOutlet weak var friendReviewTableView: UITableView!
    var friendID: String!
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func followButton(_ sender: Any) {
    }
    
    
    
    @IBAction func beenBrewButton(_ sender: Any) {
    }
    
    //segue to view friend's brewlog from their profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendToBeenSegue",
           let tabsVC = segue.destination as? BrewTabsViewController {
            tabsVC.defaultTabIndex = 0 // assuming we want to default to the "Been" tab
            tabsVC.friendID = self.friendID // or however you're storing it
        }
        if segue.identifier == "friendToWantToTrySegue",
           let tabsVC = segue.destination as? BrewTabsViewController {
            tabsVC.defaultTabIndex = 1 // now we are going to "Want to Try" tab
            tabsVC.friendID = self.friendID
        }
    }

}
