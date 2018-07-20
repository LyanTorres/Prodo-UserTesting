//
//  ForgotPasswordViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/16/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var entryBackgroundView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var feedBackLabel: UILabel!
    @IBOutlet weak var emailSentLabel: UILabel!
    @IBOutlet weak var sendEmailButton: UIButton!
    
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
    
    @IBAction func sendEmailPressed(_ sender: Any) {
        
        if(isValidEmail(email: emailTextField.text!)){
            let body = ["email": emailTextField.text!]

            URLSessionHelper.api(url: "/forgot", methodType: "POST", body: body) { ( resp ) in
                print(resp)
                if ((resp as! HTTPURLResponse).statusCode != 200) {
                    DispatchQueue.main.async {
                        self.feedBackLabel.isHidden = false
                        self.feedBackLabel.text = "Email does not match our records."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.feedBackLabel.isHidden = true
                        self.entryBackgroundView.isHidden = true
                        self.sendEmailButton.isHidden = true
                        
                        self.emailSentLabel.isHidden = false
                    }
                }
            }
            
        } else {
            feedBackLabel.isHidden = false
            self.feedBackLabel.text = "Email is not valid."
        }
    }
    
    func isValidEmail(email:String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    
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
