//
//  NetworkPasswordViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/22/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class NetworkPasswordViewController: UIViewController {

    @IBOutlet weak var textFieldBackGround: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    var ssid: String?
    var store: Store?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldBackGround.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getDeviceNameFromUser(){
        // add new device
        let alertVC = UIAlertController(title: "New Device", message: "Provide the new device's name", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.placeholder = "Device name"
        }
        let submitAction = UIAlertAction(title: "Create", style: .default, handler: {
            (alert) -> Void in
            let deviceNameTextField = alertVC.textFields![0] as UITextField
            let deviceName = deviceNameTextField.text
            
            if (deviceName != "") {
                if (self.hasName(deviceName: deviceName!)){
                    self.giveFeedBack(title: "Ops", message: "Another device already has this name, Please try again with a different one.")
                } else {
                    
                    //self.addDevice(name: deviceNameTextField.text!)
                }
            } else {
                self.giveFeedBack(title: "Ops", message: "You left the field empty, please try again.")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert) -> Void in
            print("user cancelled adding device")
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
    func giveFeedBack(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
    func hasName(deviceName: String) -> Bool {
        
        return false
    }
    
    @IBAction func connectWasPressed(_ sender: Any) {
        // TODO:- Submit password to the raspberry via the server
        if let url = URL(string:"http://192.168.4.1/signin" ) {
            print(url)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            if let password = passwordTextField.text, let ssidTemp = self.ssid{
                let postString = "ssid=\(ssidTemp)&password=\(password)&email=lyan@gmail.com"
                print(postString)
                request.httpBody = postString.data(using: .utf8)
                
                URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                    guard let _ = response,
                        let _ = data
                        else {return}
                    
                }).resume()
                }
            performSegue(withIdentifier: "goToDeviceKeyScreen", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DeviceKeyViewController{
            destination.store = store
        }
    }
}
