//
//  CreateAccountViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/3/25.
//

import UIKit
import FirebaseAuth

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

        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
                self.firstNameField.text = nil
                self.lastNameField.text = nil
                self.emailField.text = nil
                self.phoneNumberField.text = nil
                self.passwordField.text = nil
                self.reenterPasswordField.text = nil
            }
        }
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.errorLabel.text = "\(error.localizedDescription)"
            } else {
                self.errorLabel.text = ""
            }
        }
    }

}
