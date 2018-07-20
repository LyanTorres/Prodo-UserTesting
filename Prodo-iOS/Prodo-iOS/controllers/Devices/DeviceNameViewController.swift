//
//  DeviceNameViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 7/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class DeviceNameViewController: UIViewController {

    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var deviceNameTextField: UITextField!
    var store: Store?
    var key: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldBackground.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addDeviceWasPressed(_ sender: Any) {
        guard let deviceName = deviceNameTextField.text else {return}
        
        if deviceName != nil || deviceName.isEmpty {
            // it's good send it to the server
            let body = ["name":deviceName, "_store": (store?._id)!, "key":key!]
            print(body)
            URLSessionHelper.apiWithAuth(url: "/deviceLinked", user: User.currentUser()!, methodType: "POST", body: body) { (resp) in
                if ((resp as! HTTPURLResponse).statusCode != 200) {
                    DispatchQueue.main.async {
                        self.giveFeedBack(title: "Could not link Prodo device to your account!", message: "Check that the device code is correct.")
                    }
                }
                else {
                    self.performSegue(withIdentifier: "unwindToDevicesFromAddDevice", sender: nil)
                }
            }
        } else {
            giveFeedBack(title: "Add a name to your prodo device.", message: "")
        }
        
    }
    
    func giveFeedBack(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert) -> Void in
                self.performSegue(withIdentifier: "unwindToDevicesFromAddDevice", sender: nil)
            })
            
        alertVC.addAction(cancelAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    

}
