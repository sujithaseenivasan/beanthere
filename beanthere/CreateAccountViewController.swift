//
//  CreateAccountViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reenterPasswordField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!

    let segueIdentifier = "homeSegue2"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordField.isSecureTextEntry = true
        self.reenterPasswordField.isSecureTextEntry = true
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text else { return }

        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                self.errorLabel.text = "\(error.localizedDescription)"
            } else if let user = authResult?.user {
                self.errorLabel.text = ""

                // Save additional user info to Firestore
                Firestore.firestore().collection("users").document(user.uid).setData([
                    "email": email,
                    "firstName": self.firstNameField.text ?? "",
                    "lastName": self.lastNameField.text ?? "",
                    "phoneNumber": self.phoneNumberField.text ?? "",
                    "homeCity": "",
                    "notificationPreferences": NSNull(),
                    "profilePicture": NSNull(),
                    "friendsList": [],
                    "followers": [],
                    "requests": [],
                    "requested": [],
                    "reviews": []
                ]) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        UserManager.shared.u_userID = user.uid
                        print("User data saved successfully!")

                        // Clear fields
                        self.clearFields()
                        self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
                    }
                }
            }
        }
    }

    func clearFields() {
        self.firstNameField.text = nil
        self.lastNameField.text = nil
        self.emailField.text = nil
        self.phoneNumberField.text = nil
        self.passwordField.text = nil
        self.reenterPasswordField.text = nil
    }


}
