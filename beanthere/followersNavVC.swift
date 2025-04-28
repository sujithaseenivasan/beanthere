//
//  followersNavVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/18/25.
//

import UIKit

struct Friends {
    var name: String?
    var username: String?
    var picture: UIImage?
}
class followersNavVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var followersTableView: UITableView!
    var navUserId: String?
    var delegate: UIViewController!
    var followersList:[Friends] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followersTableView.delegate = self
        followersTableView.dataSource = self
        populateFollowingOrFollowersList(userID: navUserId!, followers: true){ followersList in
            if followersList.count > 0{
                self.followersList = followersList
                DispatchQueue.main.async {
                    self.followersTableView.reloadData()
                }
            }
        }
        print ("LISTS OF FOLLOWERS \(followersList)")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userFollower = self.followersList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCellID", for: indexPath) as! followersCell
            cell.delegate = self
            cell.name.text = userFollower.name
            cell.userName.text = userFollower.username
            cell.userImage.image = userFollower.picture
            makeImageOval(cell.userImage)
        return cell
        
        
    }
    

    
}



class followersCell: UITableViewCell{
    var delegate: UIViewController!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
}
