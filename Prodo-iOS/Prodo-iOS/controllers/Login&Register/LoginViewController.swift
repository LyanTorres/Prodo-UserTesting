//
//  ViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 5/30/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var entryBackgroundView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var feedBackLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryBackgroundView.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height * 0.20
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height * 0.20
            }
        }
    }
    
    @IBAction func Login(_ sender: Any) {
        let body = ["email": emailTextField.text!, "password": passwordTextField.text!]
        
        URLSessionHelper.api(url: "/users/login", methodType: "POST", body: body) { (user: User?, resp  ) in
            if ((resp as! HTTPURLResponse).statusCode != 200) {
                print("Email or password did not match.")
                
                DispatchQueue.main.async {
                    self.feedBackLabel.isHidden = false
                    self.feedBackLabel.text = "Email or password did not match"
                }
            } else {
                if let httpResponse = resp as? HTTPURLResponse {
                    if let xauth = httpResponse.allHeaderFields["X-Auth"] as? String {
                        var user = user
                        user?.token = xauth
                        User.saveCurrentUser(user: user!)
                        self.AuthCompleted()
                    }
                }
            }
        }
    }
    
    func AuthCompleted() {
        DispatchQueue.main.async {
            self.feedBackLabel.isHidden = true
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SplitViewNav") as UIViewController
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func Register(_ sender: Any) {
        performSegue(withIdentifier: "Register", sender: nil)
    }
    
    @IBAction func ForgetPassword(_ sender: Any) {
        performSegue(withIdentifier: "ForgotPassword", sender: nil)
        
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

