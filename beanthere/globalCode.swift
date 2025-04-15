//
//  globalCode.swift
//  beanthere
//
//  Created by yrone umutesi on 3/9/25.
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
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

func downloadImgWithURL(from url: URL, completion: @escaping (UIImage?) -> Void) {
    DispatchQueue.global().async {
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
}

// global load review Image given reviewID
func globLoadReviewImage(reviewId: String, completion: @escaping ([UIImage]?) -> Void) {
    let storageRef = Storage.storage().reference().child("review_images/\(reviewId)/")

    storageRef.listAll { (result, error) in
        if let error = error {
            print("Error listing images for review \(reviewId): \(error.localizedDescription)")
            completion(nil)
            return
        }

        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []

        for item in result!.items {
            dispatchGroup.enter()
            item.downloadURL { url, error in
                if let error = error {
                    print("Error getting image URL for \(item.name): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                if let url = url {
                    downloadImgWithURL(from: url) { image in
                        if let image = image {
                            print ("REVIEW PICTURES : \(image)")
                            images.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
                
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(images.isEmpty ? nil : images)
        }
    }
}

//function that given the reviewID and their new liked image it populates it
func populateReviewLikes (reviewID: String, likeNum : Int){
    let reviewRef = Firestore.firestore().collection("reviews").document(reviewID)
    reviewRef.updateData([
        "friendsLikes": likeNum
    ])
    
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
