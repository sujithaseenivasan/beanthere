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
    
    @IBOutlet weak var loginTextLabel: UILabel!
    
    @IBOutlet weak var alreadyHaveAcctTextLabel: UILabel!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextLabel.font = UIFont(name: "Manjari-Regular", size: 32)
        alreadyHaveAcctTextLabel.font = UIFont(name: "Manjari-Regular", size: 20)
        emailTextField.font = UIFont(name: "Manjari-Regular", size: 16)
        passwordTextField.font = UIFont(name: "Manjari-Regular", size: 16)
        forgotPasswordButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 16)
        createAccountButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 16)
        loginButton.titleLabel?.font = UIFont(name: "Manjari-Regular", size: 18)
        errorLabel.font = UIFont(name: "Manjari-Regular", size: 16)

        self.passwordTextField.isSecureTextEntry = true
        
        // Listener to check if a user has logged in and initiate segue
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
                self.clearFields()
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!,
                               password: passwordTextField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.errorLabel.text = "\(error.localizedDescription)"
                } else {
                    //since you are logged in set up the logOut bool to false
                    self.errorLabel.text = ""
                }
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
