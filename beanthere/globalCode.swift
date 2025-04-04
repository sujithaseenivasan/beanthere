//
//  globalCode.swift
//  beanthere
//
//  Created by yrone umutesi on 3/9/25.
//
import UIKit
import FirebaseAuth
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

// helper function to make labels oval
func makeLabelOval(_ label: UILabel) {
    label.layer.cornerRadius = label.frame.size.height / 2
    label.layer.masksToBounds = true
}

// helper function to make labels oval
func makeImageOval(_ img: UIImageView) {
    img.contentMode = .scaleAspectFill
    img.layer.cornerRadius = img.frame.size.height / 2
    img.layer.masksToBounds = true
    img.clipsToBounds = true
}

//function that helps download the image from firebase in a URL and show it  to the image screen
func downloadImage(_ img : UIImageView){
    // download image if it has a value set
    guard let urlStr = UserDefaults.standard.value(forKey: "url") as? String, let url = URL(string: urlStr) else{
        return
    }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
        guard let data = data, error == nil else{
            return
        }
        //the DispatchQueue.main is to put it on the main frame bcs it is running on a background one rn
        DispatchQueue.main.async{
            let showImg = UIImage(data: data)
            img.image = showImg
        }
    })
    task.resume()
}

// function that allows user to change their password through their email
func changePassword(_ userEmail: String) {
    Auth.auth().sendPasswordReset(withEmail: userEmail) { error in
        if let error = error {
            print("Error sending password reset: \(error.localizedDescription)")
        } else {
            print("Password reset email sent.")
        }
    }
}
