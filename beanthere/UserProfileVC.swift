//
//  UserProfileVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/9/25.
//
/*all Image manupilation functions will be globalCode.swift file*/


import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserProfileVC: UIViewController, PassUserInfo {
    
    
    @IBOutlet weak var MainName : UILabel!
    @IBOutlet weak var UserImage1 : UIImageView!
    @IBOutlet weak var Name1 : UILabel!
    @IBOutlet weak var UserName1 : UILabel!
    @IBOutlet weak var Email1 : UILabel!
    @IBOutlet weak var City1 : UILabel!
    @IBOutlet weak var Phone1 : UILabel!
    @IBOutlet weak var Notification1 : UILabel!
    var loaded_data : [String : Any]?
    let editSegue = "editProfileSegue"
    var wentToProfile : Bool = false
    var delegate: PassUserInfoToProfileView?

    override func viewDidLoad() {
        super.viewDidLoad()
        //make image round
        makeImageOval(UserImage1)
        //download image from firebase and display it
        downloadImage(self.UserImage1)
        
        //TO CHECK IS REPEATED
        UserImage1.contentMode = .scaleAspectFill
        self.UserImage1.layer.cornerRadius = self.UserImage1.frame.width / 2
        UserImage1.clipsToBounds = true
        self.UserImage1.layer.masksToBounds = true
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ _animated : Bool){
        super.viewWillAppear(true)
        wentToProfile = true
        print ("THE WENT  PROFILE BOOL VIEWWILLAPPEAR \(wentToProfile)")
        
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
            self.UserName1.text = data?["username"] as? String ?? " "
            self.Email1.text = data?["email"] as? String ?? " "
            self.Name1.text = data?["firstName"] as? String ?? " "
            self.MainName.text = self.Name1.text
            self.City1.text = data?["homeCity"] as? String ?? " "
            self.Phone1.text = data?["phoneNumber"] as? String ?? " "
            self.Notification1.text = data?["notificationPreferences"] as? String ?? " "
            
            //put all the information of currently loaded data here
            self.loaded_data = data
        }
    }
    
    //When the viewDisappear pass the data back to the main profile
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let editUserManager = UserManager(
            u_userID: UserManager.shared.u_userID,
            u_name : self.Name1.text,
            u_username: self.UserName1.text,
            u_img: self.UserImage1
        )
        if(wentToProfile){
            print ("ENTERED THE VIEWDID DISAPPEAR")
            delegate!.populateUserInfoToProfileView(info: editUserManager)
        } else {
            print ("DIDN'T ENTERED THE VIEWDID DISAPPEAR")

        }
       
        
    }
    
    //go to edit profile
    
    @IBAction func EditButton(_ sender: Any) {
        wentToProfile = false
        
    }
    
    // set logout variable to true
    
    @IBAction func LogOutButton(_ sender: Any) {
        globalDidLogOut = true
        wentToProfile = false
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
        print("WENT IN FUNCTION SEGUE")
        
        self.UserName1.text = info.u_username
        self.Email1.text = info.u_email
        self.Name1.text = info.u_name
        self.City1.text = info.u_city
        self.Phone1.text = info.u_phone
        self.Notification1.text = info.u_notifications
        self.UserImage1.image = info.u_img.image
        downloadImage(self.UserImage1)
        
    }
    
}
