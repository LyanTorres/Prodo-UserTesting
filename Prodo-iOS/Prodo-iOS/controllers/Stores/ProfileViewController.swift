//
//  ProfileViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/30/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

protocol UserLoggedOut {
    func logout()
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    var delegate: UserLoggedOut?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = User.currentUser()
        emailLabel.text = user?.email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changePasswordWasPressed(_ sender: Any) {
        
        let user = User.currentUser()
        let body = ["email": user?.email]
        
        URLSessionHelper.api(url: "/forgot", methodType: "POST", body: body) { ( resp ) in
            print(resp)
            if ((resp as! HTTPURLResponse).statusCode != 200) {
                DispatchQueue.main.async {
                    print("didn't set reset email")
                }
            } else {
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "Email sent", message: "An email to change your password has been sent!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(cancelAction)
                    alertVC.view.tintColor = UIColor.black
                    self.present(alertVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func logoutWasPressed(_ sender: Any) {
        User.eraseCurrentUser()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "initLogin")
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        guard let del = delegate else {return}
        del.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func unwindToDevicesFromProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
