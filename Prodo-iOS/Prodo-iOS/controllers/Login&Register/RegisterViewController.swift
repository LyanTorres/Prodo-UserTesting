//
//  RegisterViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/15/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
import AlertOnboarding


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var entryBackgroundView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var feedBackLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryBackgroundView.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    
    @IBAction func Register(_ sender: Any) {
        
        if (isValidEmail(email: emailTextField.text)){
            if (isPasswordValid(password: passwordTextField.text!, confirmedPassword: confirmPasswordTextField.text!)) {
                let body = ["email": emailTextField.text!, "password": passwordTextField.text!]
                
                URLSessionHelper.api(url: "/users", methodType: "POST", body: body) { (user: User?, resp  ) in
                    if ((resp as! HTTPURLResponse).statusCode != 200) {
                        print("Could not create account.")
                        DispatchQueue.main.async {
                            self.feedBackLabel.isHidden = false
                            self.feedBackLabel.text = "Something went wrong, please try again"
                        }
                    } else {
                        print("Account created")
                        DispatchQueue.main.async {
                            if let httpResponse = resp as? HTTPURLResponse {
                                if let xauth = httpResponse.allHeaderFields["X-Auth"] as? String {
                                    let defaults = UserDefaults.standard
                                    defaults.set(true, forKey: "FirstTimeUsingVideoEditor")
                                    defaults.set(true, forKey: "FirstLogin")
                                    
                                    var user = user
                                    user?.token = xauth
                                    User.saveCurrentUser(user: user!)
                                    self.segueToMain()
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            print("email is not valid")
            feedBackLabel.isHidden = false
            feedBackLabel.text = "Email is not valid"
        }
        
    }
    
    func isValidEmail(email:String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    func isPasswordValid(password: String, confirmedPassword: String) -> Bool {
        if(password != confirmedPassword){
            feedBackLabel.isHidden = false
            feedBackLabel.text = "Passwords do not match"
            return false
        }
        if (password.count < 6){
            feedBackLabel.isHidden = false
            feedBackLabel.text = "Password needs 6 characters or more"
            return false
        }
        feedBackLabel.isHidden = true
        return true
    }
    
    func segueToMain(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        self.feedBackLabel.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SplitViewNav") as UIViewController
        vc.modalTransitionStyle = .crossDissolve
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let masterViewController = leftNavController.topViewController as? StoreViewController,
            let rightNavController = splitViewController.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? DevicesCollectionViewController
            else { print(" ============= something went wrong in RegisterViewController ==============");
                return}
        
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        masterViewController.delegate = detailViewController
        self.present(vc, animated: true, completion: nil)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
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

