//
//  UserAndFriendsProtocols.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/28/25.
/*
 This file will contain all the protocols that the following View Controllers will use
 UserProfileVC, UserMainProfileVC and UserFriendsVC
 */

import UIKit
struct UserManager {
    var u_userID: String
    var u_name: String?
    var u_username: String?
    var u_email: String?
    var u_city: String?
    var u_phone: String?
    var u_pswd: String?
    var u_notifications: String?
    var u_reviews: String?
    var u_img: UIImageView!
    static var shared = UserManager(u_userID: " ")
}

// this struct will be used in the main User profile and in the view friend profile to be able to navigate to their bew logs
struct BrewLogNavCell {
    var icon: UIImage
    var title: String
    var navButton: UIButton?
}

var globalDidLogOut = false
// A shared instance of UserManager to ensure a single instance is used globally
var userChange = UserManager(u_userID: " ", u_name: " ", u_username: " ", u_email: " ", u_city: " ", u_phone: " ", u_pswd: " ", u_notifications: " ", u_img: nil)

//protocol for passing the userInformation
protocol PassUserInfo{
    func populateUserInfo(info : UserManager)
}

//protocol when you tapped the comment in the MainProfileVC review TableView
protocol MainProfileTableViewCellDel: AnyObject {
    func didTapCommentButton(reviewID: String)
}

//protocol when you tapped the comment in the FriendProfileVC review TableView
protocol FriendProfileTableViewCellDel: AnyObject {
    func didTapCommentButton2(reviewID: String)
}

/*protocol when you segue in the followers screen and delete their follower
  make it delete automatically in the tableView and the firebase and update it*/
protocol FollowersCellDelegate: AnyObject {
    func didTapDelete(for friendId: String, cell: followersCell)
}

/*protocol when you segue in the following screen and delete their following
  make it delete automatically in the tableView and the firebase and update it*/
protocol FollowingCellDelegate: AnyObject {
    func didTapDelete(for friendId: String, cell: followingCell)
}


