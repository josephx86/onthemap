//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Joseph on 5/19/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let signUpAddress = "https://auth.udacity.com/sign-up"
    let tabControllerId = "TabController"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func login(_ sender: Any) {
        // Check email address
        let emailAddress = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        if emailAddress.isEmpty {
            showAlert(message: "Please enter your email address")
            emailTextField.becomeFirstResponder()
            return
        }
        
        // Check password
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespaces)
        if password.isEmpty {
            showAlert(message: "Please enter a password")
            passwordTextField.becomeFirstResponder()
            return
        }
        
        // Try log in
        updateUi(loggingIn: true)
        HttpHelper.getUserSession(emailAddress: emailAddress, password: password, handler: handleLoginResult(success:errorMessage:response:))
    }
    
    @IBAction func signUp(_ sender: Any) {
        if let url = URL(string: signUpAddress) {
            UIApplication.shared.open(url)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        willHideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide keyboard when return is pressed
        textField.resignFirstResponder()
        return true
    }
    
    func updateUi(loggingIn: Bool) {
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func handleLoginResult(success: Bool, errorMessage: String?, response: Data?) {
        DispatchQueue.main.async {
            self.updateUi(loggingIn: false)
            if success {
                let decoder = JSONDecoder()
                if let sessionData = try? decoder.decode(SessionEndpointResponse.self, from: response!) {
                    // Save session id
                    if let appDelegate = UIApplication.shared.delegate as! AppDelegate? {
                        appDelegate.sessionId = sessionData.session.id
                    }

                    // Clear user input when session is received
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.showFirst100(sessionId: sessionData.session.id)
                } else {
                    self.showAlert(message: "Invalid email/password")
                }
            } else {
                if let errorMessage = errorMessage {
                    self.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    func showFirst100(sessionId: String) {
        if let mapController = storyboard?.instantiateViewController(withIdentifier: tabControllerId) {
            navigationController?.pushViewController(mapController, animated: true)
        }
    }
        
    @objc func willShowKeyboard() {
        // Move UI so that keyboard will not hide password box on small screens
        view.frame.origin.y -= 40
    }
    
    @objc func willHideKeyboard() {
        view.frame.origin.y = 0
    }
}
