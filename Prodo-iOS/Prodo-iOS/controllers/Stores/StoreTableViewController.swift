//
//  StoreViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/17/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import AlertOnboarding

 protocol storeSelectionDelegate: class {
    func storeSelected(_ store: Store)
}

class StoreViewController: UITableViewController {
    
    var data = [Store]()
    var selectedStore = 0
    
    // ONBOARDING
    var arrayOfImage = ["ProdoLogo", "store_icon", "tv_icon", "edit_icon"]
    var arrayOfTitle = ["WELCOME TO PRODO!", "START BY ADDING STORES ", "ADD DEVICES", "CREATE YOUR CONTENT"]
    var arrayOfDescription = ["We're here to help you manage, create, and edit your digital signage! Just follow these steps!",
                              "By adding a store you can separate your devices by store location. Just to make it easy for you!",
                              "Add devices for designated TVs in your store with specific content. Alongside, some easy to use controls and information about the device.", "We also have an in-app video editor for you to create your own gorgeous digital signage!"]
    
    var alertView = AlertOnboarding()
    weak var delegate: storeSelectionDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStores()
        
        
        // check if the it's the frist time they are using the app
        alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        setUpOnBoarding()
        
        let userDefault = UserDefaults.standard
        if(userDefault.bool(forKey: "FirstLogin")) {
            alertView.show()
            userDefault.set(false, forKey: "FirstLogin")
        }
    }
    
    func getStores() {
        if let user = User.currentUser() {
        URLSessionHelper.apiWithAuth(url: "/stores", user: user, methodType: "GET", body: nil) { (stores: [Store]?, resp) in
            guard (resp as! HTTPURLResponse).statusCode == 200 else {print(resp) ; return}
            
            DispatchQueue.main.async {
                if let stores = stores {
                    if stores.count == 0 {
                        self.tableView.emptyDataSetDataSource = self as TBEmptyDataSetDataSource
                        self.tableView.emptyDataSetDelegate = self as TBEmptyDataSetDelegate
                        self.alertView.delegate = self as AlertOnboardingDelegate
                    }
                    self.data = stores
                    self.tableView.reloadData()
                }
            }
        }
        } else {
            print("Not getting stores because nil user")
        }
    }
    
    func CreateStore(name: String, Id: String) {
        let body = ["name": name, "storeId": Id]
        URLSessionHelper.apiWithAuth(url: "/stores", user: User.currentUser()!, methodType: "POST", body: body) { ( resp ) in
            guard (resp as! HTTPURLResponse).statusCode == 200 else {return}
            DispatchQueue.main.async {
                self.getStores()
            }
        }
    }
    
    @IBAction func AddStore() {
        let alertVC = UIAlertController(title: "New store", message: "Provide store name & store identifier ", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = "Name"
        }
        alertVC.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.placeholder = "identifier"
        }
        let submitAction = UIAlertAction(title: "Create", style: .default, handler: {
            (alert) -> Void in
            //Create the new store.
            let storeNameField = alertVC.textFields![0] as UITextField
            let storeIdentifierField = alertVC.textFields![1] as UITextField
            if(storeNameField.text != "" && storeIdentifierField.text != ""){
                self.CreateStore(name: storeNameField.text!, Id: storeIdentifierField.text!)
            } else {
                self.giveFeedBack(title: "Ops", message: "You left some of the fields blank, please try again.")
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert) -> Void in
            print("user cancelled adding store")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail") {
            let controller = (segue.destination as! UINavigationController).topViewController as! DevicesCollectionViewController
            controller.store = data[selectedStore]
            
        } else if (segue.identifier == "goToProfile") {
            let destination = segue.destination as? ProfileViewController
            destination?.delegate = self
            
        }
    }
    
}

// MARK: UICollectionViewDataSource

extension StoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "store_cell", for: indexPath) as? StoreTableViewCell
        cell?.storeNameLabel.text = data[indexPath.row].name
        cell?.storeIdentifierLabel.text = data[indexPath.row].storeId
        //cell?.storeIdentifierLabel.text = data[indexPath.row]
        let type = data[indexPath.row].devices.count == 1 ? " device" : " devices"
        cell?.deviceCountLabel.text = String(data[indexPath.row].devices.count) + type
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStore = indexPath.row
        delegate?.storeSelected(data[selectedStore])
        
        if let detailViewController = delegate as? DevicesCollectionViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
        
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertVC = UIAlertController(title: "Deleting store", message: "Are you sure you want to erase the store: \(data[indexPath.row].name)", preferredStyle: .alert)
            let submitAction = UIAlertAction(title: "DELETE", style: .destructive, handler: {
                (alert) -> Void in
                URLSessionHelper.apiWithAuth(url: "/store/\(self.data[indexPath.row]._id)", user: User.currentUser()!, methodType: "DELETE", body: nil, completion: { (res) in
                })
                self.data.remove(at: indexPath.row)
                // TODO:- delete it from the actual server
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert) -> Void in
                print("user cancelled deleting store")
            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(submitAction)
            alertVC.view.tintColor = UIColor.black
            present(alertVC, animated: true)
        }
    }
    
}

extension StoreViewController: TBEmptyDataSetDataSource {
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        // return the image for EmptyDataSet
        return #imageLiteral(resourceName: "store_icon")
    }
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        // return the title for EmptyDataSet
        return NSAttributedString(string: "No stores")
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        // return the description for EmptyDataSet
        return NSAttributedString(string: "Press the \"+\" button up top to add a new store!" )
    }
    
    func backgroundColorForEmptyDataSet(in scrollView: UIScrollView) -> UIColor? {
        // return the backgroundColor for EmptyDataSet
        return nil
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        // return the vertical offset for EmptyDataSet, default is 0
        return -80
    }
    
}

extension StoreViewController: TBEmptyDataSetDelegate{
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        // should display EmptyDataSet or not, default is true
        return data.count == 0
    }
}

extension StoreViewController: UserLoggedOut {
    func logout() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension StoreViewController: AlertOnboardingDelegate{
    
    func alertOnboardingCompleted() {
        print("on boarding completed, going to main")
    }
    
    func alertOnboardingNext(_ nextStep: Int) {
        print("on boarding went to next screen")
    }
    
    
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int) {
        print("Onboarding skipped the \(currentStep) step and the max step he saw was the number \(maxStep)... Going to main anyway")
    }
    
    func setUpOnBoarding(){
        //Modify background color of AlertOnboarding
        self.alertView.colorForAlertViewBackground = UIColor(red: 36/255, green: 35/255, blue: 35/255, alpha: 1.0)
        
        //Modify colors of AlertOnboarding's button
        self.alertView.colorButtonText = UIColor.white
        self.alertView.colorButtonBottomBackground = UIColor(red: 249/255, green: 151/255, blue: 34/255, alpha: 1.0)
        
        //Modify colors of labels
        self.alertView.colorTitleLabel = UIColor.white
        self.alertView.colorDescriptionLabel = UIColor.white
        
        //Modify colors of page indicator
        self.alertView.colorPageIndicator = UIColor.white
        self.alertView.colorCurrentPageIndicator = UIColor(red: 65/255, green: 165/255, blue: 115/255, alpha: 1.0)
        
        //Modify size of alertview (Purcentage of screen height and width)
        self.alertView.percentageRatioHeight = 0.75
        self.alertView.percentageRatioWidth = 0.75
        
        //Modify labels
        self.alertView.titleSkipButton = "SKIP"
        self.alertView.titleGotItButton = "UNDERSTOOD !"
    }
}                                                                                                                                                                                                          
