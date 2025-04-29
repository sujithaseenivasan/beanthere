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
class UserSettingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var City: UITextField!
    @IBOutlet weak var Phone: UITextField!
    @IBOutlet weak var nameDummy: UILabel!
    @IBOutlet weak var userNameDummy: UILabel!
    @IBOutlet weak var emailDummy: UILabel!
    @IBOutlet weak var cityDummy: UILabel!
    @IBOutlet weak var phoneDummy: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    
    @IBOutlet weak var notifPreferencesLabel: UILabel!
    private var reviewListeners: [String: ListenerRegistration] = [:]

    private var friendIds: [String] = []
    private var friendReviewCounts: [String: Int] = [:] // friendId -> number of reviews known



    @IBOutlet weak var notificationPicker: UIPickerView!
    var notificationOptions = ["Off", "Every Minute", "Hourly", "Daily"]
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    var loaded_data : [String : Any]?
    var delegate: PassUserInfo?
    private let storageRef = Storage.storage().reference()
    var didPicChange = false

    
override func viewDidLoad() {
    super.viewDidLoad()
    notificationPicker.delegate = self
    notificationPicker.dataSource = self
    // Load saved preference
    if let savedOption = UserDefaults.standard.string(forKey: "NotificationFrequency"),
       let savedRow = notificationOptions.firstIndex(of: savedOption) {
        notificationPicker.selectRow(savedRow, inComponent: 0, animated: false)
        scheduleNotification(with: savedOption)
    } else {
        // Default to "Off" if nothing saved
        scheduleNotification(with: "Off")
    }
    
    changeFonts()
    //make image round
    makeImageOval(userImage)
    userImage.contentMode = .scaleAspectFill
    userImage.clipsToBounds = true
    
    editButton.titleLabel?.numberOfLines = 1
    editButton.titleLabel?.lineBreakMode = .byTruncatingTail
    editButton.titleLabel?.adjustsFontSizeToFitWidth = true
    editButton.titleLabel?.baselineAdjustment = .alignCenters
    editButton.setTitle("Edit Picture", for: .normal)
    
    //let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
    //darkModeSwitch.isOn = isDarkMode
}
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notificationOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = notificationOptions[row]
        label.textAlignment = .center
        label.font = UIFont(name: "Lora-SemiBold", size: 17) // Your custom font
        label.textColor = .darkGray

        return label
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
        
        self.fetchUserImage(userId: currentUID){ image in
            if let image = image {
                DispatchQueue.main.async {
                    self.userImage.image = image
                }
            }else {
                self.userImage.image = nil
            }
        }
        
        // Retrieve the fields from the Firestore document
        let data = document.data()
        let firstName = data?["firstName"] as? String ?? ""
        let lastName = data?["lastName"] as? String ?? ""
        var tempUserName: String = "@" + firstName  + lastName
        
        self.Username.text = tempUserName
        self.Email.text = data?["email"] as? String ?? " "
        self.Name.text = firstName
        self.City.text = data?["homeCity"] as? String ?? " "
        self.Phone.text = data?["phoneNumber"] as? String ?? " "
        
        // Store all the information of currently loaded data
        self.loaded_data = data
    }
}
    // functions that fetches userImages from firebase
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

    
    //function that changes all the fonts
    func changeFonts(){
        Username.font = UIFont(name: "Lora-SemiBold", size: 17)
        Name.font = UIFont(name: "Lora-SemiBold", size: 17)
        Email.font = UIFont(name: "Lora-SemiBold", size: 17)
        City.font = UIFont(name: "Lora-SemiBold", size: 17)
        Phone.font = UIFont(name: "Lora-SemiBold", size: 17)
        nameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        userNameDummy.font = UIFont(name: "Lora-Bold", size: 17)
        emailDummy.font = UIFont(name: "Lora-Bold", size: 17)
        cityDummy.font = UIFont(name: "Lora-Bold", size: 17)
        phoneDummy.font = UIFont(name: "Lora-Bold", size: 17)
        editButton.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 17)
        notifPreferencesLabel.font = UIFont(name: "Lora-Bold", size: 17)
        //darkModeLabel.font = UIFont(name: "Lora-Bold", size: 17)
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
    
    if(didPicChange){
        changed = true
    }
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
            u_img: self.userImage
        )

        delegate?.populateUserInfo(info: editUserManager)
        self.navigationController?.popViewController(animated: true)
    }

    
    
    // function for user to change their password
    @IBAction func resetPassword(_ sender: Any) {
        changePassword((Auth.auth().currentUser!.email)!)
    }
    
    
    @IBAction func darkModeTogglePressed(_ sender: UISwitch) {
        if sender.isOn {
            overrideUserInterfaceStyleForAllWindows(style: .dark)
        }
        else {
            overrideUserInterfaceStyleForAllWindows(style: .light)
        }
        
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
    }
    
    // MARK: - Notification Handling

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = notificationOptions[row]
        UserDefaults.standard.set(selectedOption, forKey: "NotificationFrequency")
        
        // Clear all previously scheduled notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ Cleared all pending notifications.")

        // Then schedule a new notification
        sendLocalNotificationForNewReview()
    }

    // Schedules a notification based on user's wantToTry list
    private func sendLocalNotificationForNewReview() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("❌ No current user ID.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("✅ Successfully fetched user document.")
                let data = document.data()
                let wantToTryIDs = data?["wantToTry"] as? [String] ?? []

                if let randomWantToTryID = wantToTryIDs.randomElement() {
                    print("✅ Found wantToTry cafe ID: \(randomWantToTryID)")
                    
                    // Fetch the cafe's name
                    db.collection("coffeeShops").document(randomWantToTryID).getDocument { cafeDoc, _ in
                        if let cafeDoc = cafeDoc, cafeDoc.exists,
                           let cafeData = cafeDoc.data(),
                           let cafeName = cafeData["name"] as? String {
                            print("✅ Found cafe name: \(cafeName)")
                            self.scheduleNotification(with: "Check out \(cafeName)! ☕️")
                        } else {
                            print("⚠️ Cafe document not found or missing name. Falling back to default message.")
                            self.scheduleNotification(with: "Come back to check out new cafes! ☕️")
                        }
                    }
                } else {
                    print("⚠️ wantToTry list is empty. Sending default notification.")
                    self.scheduleNotification(with: "Come back to check out new cafes! ☕️")
                }
            } else {
                print("❌ Failed to fetch user document: \(error?.localizedDescription ?? "Unknown error")")
                self.scheduleNotification(with: "Come back to check out new cafes! ☕️")
            }
        }
    }

    // Helper function to schedule the local notification
    private func scheduleNotification(with body: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Cafe Recommendation!"
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to add notification request: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled with body: \"\(body)\"")
            }
        }
    }

    
}


    

