//
//  MainUserProfileVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/2/25.
//

import UIKit

class MainUserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var userProfileUsername: UILabel!
    
    @IBOutlet weak var followersNum: UILabel!
    
    @IBOutlet weak var followingsNum: UILabel!
    
    
    @IBOutlet weak var userBrewLogTableView: UITableView!
    
    
    @IBOutlet weak var userReviewsTableView: UITableView!
    let valCellIndetifier = "valCellID"
    override func viewDidLoad() {
        super.viewDidLoad()

        // from firebase download the image and make it round
        downloadImage(self.userProfileImg)
        makeImageOval(self.userProfileImg)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: valCellIndetifier, for: indexPath as IndexPath)
        return cell
    }

}
