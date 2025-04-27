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
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var nameDummy: UILabel!
    @IBOutlet weak var usernameDummy: UILabel!
    @IBOutlet weak var emailDummy: UILabel!
    @IBOutlet weak var cityDummy: UILabel!
    @IBOutlet weak var PhoneDummy: UILabel!
    var userID : String?
    var loaded_data : [String : Any]?
    let editSegue = "editProfileSegue"
    var wentToProfile : Bool = false
    var delegate: PassUserInfoToProfileView?
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //change the fonts
        changeFonts()

        //make image round
        makeImageOval(UserImage1)
        //TO CHECK IS REPEATED
        UserImage1.contentMode = .scaleAspectFill
        self.UserImage1.layer.cornerRadius = self.UserImage1.frame.width / 2
        UserImage1.clipsToBounds = true
        self.UserImage1.layer.masksToBounds = true
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkMode
    }
    
    //In will appear that is where we load every instance of settings
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wentToProfile = true
        print("THE WENT PROFILE BOOL VIEWWILLAPPEAR \(wentToProfile)")
        
        // Use current user's UID from Firebase Auth
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        self.userID = currentUID
        
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
            
            let data = document.data()
            let firstName = data?["firstName"] as? String ?? ""
            let lastName = data?["lastName"] as? String ?? ""
            var tempUserName: String = "@" + firstName + lastName
            
            self.UserName1.text = tempUserName
            self.Email1.text = data?["email"] as? String ?? " "
            self.Name1.text = firstName
            self.MainName.text = self.Name1.text
            self.City1.text = data?["homeCity"] as? String ?? " "
            self.Phone1.text = data?["phoneNumber"] as? String ?? " "
            
            self.fetchUserImage(userId: self.userID!){ image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.UserImage1.image = image
                    }
                }else {
                    self.UserImage1.image = nil
                }
            }
            // Store the loaded user data if needed later
            self.loaded_data = data
            
        }
    }

    
    //When the viewDisappear pass the data back to the main profile
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let editUserManager = UserManager(
            u_userID: Auth.auth().currentUser?.uid ?? "",
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
    
    //function that changes all the fonts
    func changeFonts(){
        MainName.font = UIFont(name: "Lora-SemiBold", size: 15)
        Name1.font = UIFont(name: "Lora-Regular", size: 15)
        UserName1.font = UIFont(name: "Lora-Regular", size: 15)
        Email1.font = UIFont(name: "Lora-Regular", size: 15)
        City1.font = UIFont(name: "Lora-Regular", size: 15)
        Phone1.font = UIFont(name: "Lora-Regular", size: 15)
        nameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        usernameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        emailDummy.font = UIFont(name: "Lora-Bold", size: 17)
        cityDummy.font = UIFont(name: "Lora-Bold", size: 17)
        PhoneDummy.font = UIFont(name: "Lora-Bold", size: 17)
        edit.titleLabel?.font = UIFont(name: "Lora-Bold", size: 17)
        logOut.titleLabel?.font = UIFont(name: "Lora-Bold", size: 17)
    }
    
    //go to edit profile
    @IBAction func EditButton(_ sender: Any) {
        wentToProfile = false
        
    }
    
    // set logout variable to true
    
    @IBAction func LogOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true)
        } catch {
            print("Sign Out error")
        }
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
    }
    
    // functions that fetches userImages from firebase
    func fetchUserImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage()
        let imagePath = "images/\(userId)_file.png"
        let imagePath2 = "images/\(userId)file.png"
        let imageRef = storage.reference(withPath: imagePath)
        let imageRef2 = storage.reference(withPath: imagePath2)

        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                imageRef2.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        print("Image fetched 2successfully.")
                        completion(image)
                    } else {
                        print("Failed2 to convert data to image.")
                        completion(nil)
                    }
                }
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
    
    
    @IBAction func darkModeSwitchToggle(_ sender: UISwitch) {
        if sender.isOn {
            overrideUserInterfaceStyleForAllWindows(style: .dark)
        }
        else {
            overrideUserInterfaceStyleForAllWindows(style: .light)
        }
        
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
    }
    
    
}
