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

//protocol to pass info back to the MainUser Profile
protocol PassUserInfoToProfileView{
    func populateUserInfoToProfileView(info : UserManager)
}

protocol MainProfileTableViewCellDel: AnyObject {
    func didTapCommentButton(reviewID: String)
}

protocol FriendProfileTableViewCellDel: AnyObject {
    func didTapCommentButton2(reviewID: String)
}


