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
    @IBOutlet weak var nameDummy: UILabel!
    @IBOutlet weak var userNameDummy: UILabel!
    @IBOutlet weak var emailDummy: UILabel!
    @IBOutlet weak var cityDummy: UILabel!
    @IBOutlet weak var notifDummy: UILabel!
    @IBOutlet weak var phoneDummy: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var save: UIButton!
    
var loaded_data : [String : Any]?
var delegate: PassUserInfo?
private let storageRef = Storage.storage().reference()
var didPicChange = false

    
override func viewDidLoad() {
    super.viewDidLoad()
    changeFonts()
    //make image round
    makeImageOval(userImage)
    //download image from firebase and display it
    downloadImage(self.userImage)
    
    userImage.contentMode = .scaleAspectFill
    userImage.clipsToBounds = true
}
    

//In will appear that is where we load every instance of settings
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Use Firebase Auth to get the currently authenticated user's UID
    guard let currentUID = Auth.auth().currentUser?.uid else {
        print("No authenticated user found.")
        return
    }
    
    let userField = Firestore.firestore().collection("users").document(currentUID)
    userField.getDocument { (docSnap, error) in
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
        
        // Store all the information of currently loaded data
        self.loaded_data = data
    }
}
    //function that changes all the fonts
    func changeFonts(){
        Username.font = UIFont(name: "Lora-SemiBold", size: 17)
        Name.font = UIFont(name: "Lora-SemiBold", size: 17)
        Email.font = UIFont(name: "Lora-SemiBold", size: 17)
        City.font = UIFont(name: "Lora-SemiBold", size: 17)
        Phone.font = UIFont(name: "Lora-SemiBold", size: 17)
        Notification.font = UIFont(name: "Lora-SemiBold", size: 17)
        nameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        userNameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        emailDummy.font = UIFont(name: "Lora-Bold", size: 17)
        cityDummy.font = UIFont(name: "Lora-Bold", size: 17)
        notifDummy.font = UIFont(name: "Lora-Bold", size: 17)
        phoneDummy.font = UIFont(name: "Lora-Bold", size: 17)
        editButton.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 17)
        resetButton.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 17)
        save.titleLabel?.font = UIFont(name: "Lora-Bold", size: 17)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Ensure there's a logged-in user
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        
        // Get the edited image
        guard let img = info[.editedImage] as? UIImage else {
            print("No edited image found.")
            return
        }
        
        // Convert image to PNG data
        guard let imgData = img.pngData() else {
            print("Failed to convert image to PNG data.")
            return
        }
        
        let imagePath = "images/\(currentUID)_file.png"
        
        // Upload image data to Firebase Storage
        storageRef.child(imagePath).putData(imgData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload image: \(error!.localizedDescription)")
                return
            }
            
            // Get download URL after successful upload
            self.storageRef.child(imagePath).downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("Failed to get download URL: \(error!.localizedDescription)")
                    return
                }
                
                let urlStr = url.absoluteString
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.userImage.image = img
                    self.userImage.layer.cornerRadius = self.userImage.frame.width / 2
                    self.userImage.layer.masksToBounds = true
                }
                
                print("Download URL: \(urlStr)")
                // Save download URL to UserDefaults
                UserDefaults.standard.set(urlStr, forKey: "url")
            }
        }
    }


    //function 2 for UIImagePickerControllerDelegate (what happens when the picker is canceled)
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }

    // function to update the fields when they are being typed in so that if they are changed the changes also reflect in the firebase storage. Save every changes when you exist the page
    @IBAction func SaveChanges(_ sender: Any) {
        // Exit early if user info hasn't changed
        guard didUserInfoChange() else { return }

        // Ensure current user is authenticated
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }

        // Ensure we have loaded data to update
        guard let updatedData = self.loaded_data else {
            print("No user data loaded to save.")
            return
        }

        // Reference Firestore user document
        let userField = Firestore.firestore().collection("users").document(currentUID)

        // Save the updated data
        userField.setData(updatedData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }

        // Update UserManager and call delegate
        let editUserManager = UserManager(
            u_userID: currentUID,
            u_name: self.Name.text,
            u_username: self.Username.text,
            u_email: self.Email.text,
            u_city: self.City.text,
            u_phone: self.Phone.text,
            u_notifications: self.Notification.text,
            u_img: self.userImage
        )

        delegate?.populateUserInfo(info: editUserManager)
        self.navigationController?.popViewController(animated: true)
    }

    
    // function for user to change their password
    @IBAction func resetPassword(_ sender: Any) {
        changePassword((Auth.auth().currentUser!.email)!)
    }
}
    
    

    

