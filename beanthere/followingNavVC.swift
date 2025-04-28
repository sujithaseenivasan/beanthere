//
//  followingNavVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit

class followingNavVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var followingTableView: UITableView!
    var navUserId: String!
    var delegate: UIViewController!
    var followingList:[Friends] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followingTableView.delegate = self
        followingTableView.dataSource = self
        populateFollowingOrFollowersList(userID: navUserId!, followers: false){ followingList in
            if followingList.count > 0{
                self.followingList = followingList
                DispatchQueue.main.async {
                    self.followingTableView.reloadData()
                }
            }
        }
        print ("LISTS OF FOLLOWERS \(followingList)")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userFollower = self.followingList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCellID", for: indexPath) as! followersCell
            cell.delegate = self
            cell.name.text = userFollower.name
            cell.userName.text = userFollower.username
            cell.userImage.image = userFollower.picture
            makeImageOval(cell.userImage)
        return cell
        
        
    }
}


class followingCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
}
