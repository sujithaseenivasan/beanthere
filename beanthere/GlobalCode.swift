//
//  globalCode.swift
//  beanthere
//
//  Created by yrone umutesi on 3/9/25.
/* Because of a lot of similarities of code in different view controllers like
   we created this globalcode file to take most code that we will call on across
   multiple view controllers that does the same thing. To avoid code repetition
 */

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

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

//function that extracts user image given userID from firebase and return an image
func fetchUserImage(userId: String, completion: @escaping (UIImage?) -> Void) {
    let storage = Storage.storage()
    let imagePath = "images/\(userId)_file.png"
    let imageRef = storage.reference(withPath: imagePath)

    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            completion(nil)
            return
        }

        if let data = data, let image = UIImage(data: data) {
            print("Image fetched successfully.")
            completion(image)
        } else {
            print("Failed to convert data to image.")
            completion(nil)
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

/* this function helps the followingNavVC and the followersNavVC, given the
    usersID and true if you want to receive the list of followers or false if you
    want the followings lists
 */
func populateFollowingOrFollowersList(userID: String, followers: Bool, completion: @escaping ([Friends]) -> Void) {
    var followingOrFollowersList: [Friends] = []
    
    let userField = db.collection("users").document(userID)
    userField.getDocument { (docSnap, error) in
        //if user have an error guard it
        if let error = error {
            print("Error fetching user data: \(error.localizedDescription)")
            return
        }
        guard let document = docSnap, document.exists else {
            print("User document does not exist")
            return
        }
        
        // Retrieve the fields from the Firestore document
        let data = document.data()
        //if it is true loop through the followers list else loop through the following list
        var listIDs = data?["followers"] as? [String] ?? []
        if (!followers){
            listIDs = data?["friendsList"] as? [String] ?? []
        }
        
        // now loop through the list and append each user to the followingOrFollowersList, wait for all sync fetchs
        let group = DispatchGroup()
        for userID in listIDs {
            group.enter()
            getUserFriends(userID: userID) { friend in
                if let friend = friend {
                    followingOrFollowersList.append(friend)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(followingOrFollowersList)
        }
        
    }
}

/* function that is a helper to the populateFollowingOrFollowersList that given the userID it
 will return it's Friends struct*/
func getUserFriends(userID: String,  completion: @escaping (Friends?) -> Void){
    let userField = db.collection("users").document(userID)
    print("PRINT FRIENDS ID \(userID)")
    userField.getDocument { (docSnap, error) in
        if let error = error {
            print("Error fetching user data: \(error.localizedDescription)")
            completion(nil)
            return
        }
        guard let document = docSnap, document.exists else {
            print("User document does not exist")
            completion(nil)
            return
        }
        // Retrieve the fields from the Firestore document
        let data = document.data()
        let firstname = data?["firstName"] as? String ?? ""
        let lastName = data?["lastName"] as? String ?? ""
        let username = "@" + firstname + lastName
        var tempImg = UIImage()
        fetchUserImage(userId: userID){image in
            DispatchQueue.main.async {
                let userImage = image ?? UIImage()
                let userFriends = Friends(name: firstname, username: username, picture: userImage)
                completion(userFriends)
                }
        }
    }
   
}

