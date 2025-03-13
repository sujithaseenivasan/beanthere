//
//  UserSettingVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/4/25.
//
/*all Image manupilation functions will be globalCode.swift file*/


import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
// tabView struct
//struct TabView<SelectionValue, Content> where Selection
//Value : Hashable, Content : View
class UserSettingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

@IBOutlet weak var Username: UITextField!
@IBOutlet weak var Name: UITextField!
@IBOutlet weak var userImage: UIImageView!
@IBOutlet weak var Email: UITextField!
@IBOutlet weak var City: UITextField!
@IBOutlet weak var Phone: UITextField!
@IBOutlet weak var Notification: UITextField!
var loaded_data : [String : Any]?
var delegate: PassUserInfo?
private let storageRef = Storage.storage().reference()
var didPicChange = false

override func viewDidLoad() {
    super.viewDidLoad()
    //make image round
    makeImageOval(userImage)
    
    //download image from firebase and display it
    downloadImage(self.userImage)
    
    userImage.contentMode = .scaleAspectFill
    userImage.clipsToBounds = true
}

//In will appear that is where we load every instance of settings
override func viewWillAppear(_ _animated : Bool){
    super.viewWillAppear(true)
    var settingUID = UserManager.shared.u_userID
    
    // search in firebase if you find the user populate the users information in the swift fields
    let userField = Firestore.firestore().collection("users").document(settingUID)
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
        self.Username.text = data?["username"] as? String ?? " "
        self.Email.text = data?["email"] as? String ?? " "
        self.Name.text = data?["firstName"] as? String ?? " "
        self.City.text = data?["homeCity"] as? String ?? " "
        self.Phone.text = data?["phoneNumber"] as? String ?? " "
        self.Notification.text = data?["notificationPreferences"] as? String ?? " "
        
        //put all the information of currently loaded data here
        self.loaded_data = data
    }
}

//before going to the hardware first see if the user information was changed
func didUserInfoChange() -> Bool{
    var changed = false
  
    if self.loaded_data!["username"] as? String != self.Username.text! {
        self.loaded_data!["username"] = self.Username.text
        print("CODE ENTERED USERNAME")
        changed = true
    }
    if self.loaded_data!["email"] as? String != self.Email.text {
        self.loaded_data!["email"] = self.Email.text
        changed = true
    }
    if self.loaded_data!["firstName"] as? String != self.Name.text {
        self.loaded_data!["firstName"] = self.Name.text
        changed = true
    }
    if self.loaded_data!["homeCity"] as? String != self.City.text {
        self.loaded_data!["homeCity"] = self.City.text
        changed = true
    }
    if self.loaded_data!["phoneNumber"] as? String != self.Phone.text {
        self.loaded_data!["phoneNumber"] = self.Phone.text
        changed = true
    }
    if self.loaded_data!["notificationPreferences"] as? String != self.Notification.text {
        self.loaded_data!["notificationPreferences"] = self.Notification.text
        changed = true
    }
    if(didPicChange){
        changed = true
    }
    //COMEBACK FOR THE PICTURE PASS
    print("CODE ENTERED CHANGE")
    return changed
}

// function that will help us upload user photo when click on the button
  @IBAction func editPhotoButton(_ sender: Any) {
      didPicChange = true
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      present(picker, animated: true)
  }

//function 1 for UIImagePickerControllerDelegate (called when user finishes picking a so we wouldn't grab photo from  in here)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true)
        //allows editing, has to be an image
        guard let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{return}
        //get bytes of the image
        guard let imgData = img.pngData() else {return}
        //upload bytes of our image data (don't care about metadata
        storageRef.child("images/\(UserManager.shared.u_userID)file.png").putData(imgData, metadata: nil) { _, error in
            guard error == nil else {
                print("failed to upload \(error!.localizedDescription) ")
                return
            }
            
            //then convert them to download url , get a reference to the url (the path)
            self.storageRef.child("images/\(UserManager.shared.u_userID)file.png").downloadURL(completion: { url, error in
                guard let url = url, error == nil else{
                    print("failed to downloadURL \(error!.localizedDescription) ")
                    return}
                let urlStr = url.absoluteString
                DispatchQueue.main.async{
                    self.userImage.image = img
                    self.userImage.layer.cornerRadius = self.userImage.frame.width / 2
                        self.userImage.layer.masksToBounds = true
                }
                print("Download URL: \(urlStr)")
                //save it to userdefaults to be used to download latest image after
                UserDefaults.standard.set(urlStr, forKey: "url")
            })
        }
    }

    //function 2 for UIImagePickerControllerDelegate (what happens when the picker is canceled)
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }

    // function to update the fields when they are being typed in so that if they are changed the changes also reflect in the firebase storage. Save every changes when you exist the page
    @IBAction func SaveChanges(_ sender: Any) {
        // if the information didn't change exit the function
        if(!didUserInfoChange()) {return}
        //now that it changed update update it to firebase
        let userField = Firestore.firestore().collection("users").document(UserManager.shared.u_userID)
        //Update if the data were changed
        userField.setData(self.loaded_data!, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }
        let editUserManager = UserManager(
            u_userID: UserManager.shared.u_userID,
            u_name : self.Name.text,
            u_username: self.Username.text,
            u_email : self.Email.text,
            u_city : self.City.text,
            u_phone : self.Phone.text,
            u_notifications : self.Notification.text,
            u_img: self.userImage
        )
        delegate!.populateUserInfo(info: editUserManager)
        self.navigationController?.popViewController(animated: true)
    }
    
    // function for user to change their password
    @IBAction func resetPassword(_ sender: Any) {
        changePassword((Auth.auth().currentUser!.email)!)
    }
}
    
    

    

