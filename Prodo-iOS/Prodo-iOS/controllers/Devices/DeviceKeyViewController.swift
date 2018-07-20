//
//  DeviceKeyViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 7/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class DeviceKeyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var digitTextField: UITextField!
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var textFieldBacground2: UIView!
    @IBOutlet weak var digitTextField2: UITextField!
    var store: Store?
    var key: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldBackground.layer.cornerRadius = 5
        textFieldBacground2.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextWasPressed(_ sender: Any) {
        
        guard let keyString = digitTextField.text, let keyString2 = digitTextField2.text else {return}
        
        if keyString.count == 4 && keyString2.count == 4 {
            
            if !keyString.isEmpty && !keyString2.isEmpty {
            // then trnasition to next screen and do your thing
                key = "\(keyString)-\(keyString2)"
                print(key)
                performSegue(withIdentifier: "toDeviceName", sender: nil)
                
            } else {
                //key had something other than numbers
                giveFeedBack(title: "Oops", message: "You entered in something other than numbers. Please look at your device and enter the 8 digit number on the screen.")
                digitTextField.text = ""
                digitTextField2.text = ""
            }
        } else {
              giveFeedBack(title: "Oops", message: "You entered in the wrong key. Please look at your device and enter the 8 digit number on the screen.")
            digitTextField.text = ""
            digitTextField2.text = ""
        }
        
    }
    
    func giveFeedBack(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 1
//        let currentString: NSString = textField.text! as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }
//
    @IBAction func retryWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToWifiSelection", sender: nil)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DeviceNameViewController {
            destination.store = self.store
            destination.key = self.key
        }
    }
    
}
