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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
