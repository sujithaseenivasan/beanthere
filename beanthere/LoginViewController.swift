//
//  LoginViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/3/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let segueIdentifier = "homeSegue1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!,
                           password: passwordTextField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.errorLabel.text = "\(error.localizedDescription)"
            } else if let user = authResult?.user {
                //since you are logged in set up the logOut bool to false
                globalDidLogOut = false
                self.errorLabel.text = ""
                UserManager.shared.u_userID = user.uid
                self.clearFields()
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
                
            }
        }
    }
    
    func clearFields() {
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        changePassword(emailTextField.text!)
    }
}
