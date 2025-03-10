//
//  UserProfileVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/9/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class UserProfileVC: UIViewController, PassUserInfo {
    
    @IBOutlet weak var Name1: UILabel!
    @IBOutlet weak var UserName1: UILabel!
    @IBOutlet weak var Email1: UILabel!
    @IBOutlet weak var City1: UILabel!
    @IBOutlet weak var Phone1: UILabel!
    @IBOutlet weak var Pswd1: UILabel!
    @IBOutlet weak var Notification1: UILabel!
    var loaded_data : [String : Any]?
    
    let editSegue = "editProfileSegue"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            self.UserName1.text = data?["username"] as? String ?? " "
            self.Email1.text = data?["email"] as? String ?? " "
            self.Name1.text = data?["firstName"] as? String ?? " "
            self.City1.text = data?["homeCity"] as? String ?? " "
            self.Phone1.text = data?["phoneNumber"] as? String ?? " "
            self.Notification1.text = data?["notificationPreferences"] as? String ?? " "
            
            //put all the information of currently loaded data here
            self.loaded_data = data
        }
    }
    
    //go to edit profile
    
    @IBAction func EditButton(_ sender: Any) {
        
    }
    
    //overwrite do the connection  between the 2 screens and the main screen
    override func prepare( for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == editSegue,
           let settingVC = segue.destination as? UserSettingVC{
            settingVC.delegate = self
        }
    }
    
    //function to populate user informations in the struct and pass it along
    func populateUserInfo(info: UserManager) {
        self.UserName1.text = userChange.u_username
        self.Email1.text = userChange.u_email
        self.Name1.text = userChange.u_name
        self.City1.text = userChange.u_city
        self.Phone1.text = userChange.u_phone
        self.Notification1.text = userChange.u_notifications
    }
    
}
