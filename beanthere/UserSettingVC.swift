//
//  UserSettingVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
// tabView struct
//struct TabView<SelectionValue, Content> where Selection
//Value : Hashable, Content : View
class UserSettingVC: UIViewController{
    
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var City: UITextField!
    
    @IBOutlet weak var Phone: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet weak var Notification: UITextField!
    var loaded_data : [String : Any]?
    var delegate: PassUserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make image round
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        
        //Add code to the things that segue to remove back button and reallocate segue
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        var settingUID = UserManager.shared.u_userID
        print ("USER ID IS \(settingUID) 1 ")
        
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
        print("CODE ENTERED CHANGE")
        return changed
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
        var editUserManager = UserManager(
            u_userID: UserManager.shared.u_userID,
            u_name : self.Name.text,
            u_username: self.Username.text,
            u_email : self.Email.text,
            u_city : self.City.text,
            u_phone : self.Phone.text,
            u_notifications : self.Notification.text
        )
        delegate!.populateUserInfo(info: editUserManager)
        self.navigationController?.popViewController(animated: true)
        
        }
        
}
    
    

    

