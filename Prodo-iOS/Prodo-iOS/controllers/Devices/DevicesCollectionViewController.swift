//
//  DevicesCollectionViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

private let reuseIdentifier = "device_cell"

class DevicesCollectionViewController: UICollectionViewController {
    var store: Store?
    var devices = [Device]()
    var selectedDevice: Device?
    var addedDevice: String?
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        
        if let _ = store {
            getDevices()
            activityIndicator()
            indicator.startAnimating()
            indicator.hidesWhenStopped = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0,y:  0,width:  40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    func addDevice(name: String) {
        if let storeId = store?._id {
            let body = ["name": name, "key": "313124312", "_store": storeId]
            URLSessionHelper.apiWithAuth(url: "/device", user: User.currentUser()!, methodType: "POST", body: body) { (device: Device?, resp ) in
                print(resp)
                guard (resp as! HTTPURLResponse).statusCode == 200 else {return}
                DispatchQueue.main.async {
                    self.devices.insert(device!, at: 0)
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    func getDevices()  {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        guard let storeTemp = store else{print("Store is nil"); return}
        URLSessionHelper.apiWithAuth(url: "/"+storeTemp._id+"/devices", user: User.currentUser()!, methodType: "GET", body: nil) { (devices: [Device]?, resp ) in
            guard (resp as! HTTPURLResponse).statusCode == 200 else {self.indicator.stopAnimating() ; print(resp) ; return}
            print(resp)
            DispatchQueue.main.async {
                if let devices = devices {
                    self.devices = devices
                    self.devices.append(Device(_id: "", name: "newDeviceCollectionViewCell", contentLinks: "", thumbnailLink:""))
                    self.collectionView?.reloadData()
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navVC = segue.destination as? UINavigationController {
            
            if let destination  = navVC.topViewController as? DeviceSettingsViewController {
                guard let device = selectedDevice, let storeTemp = store else {return}
                destination.device = device
                destination.store = storeTemp
                destination.delegate = self as! DeviceDeleted
                
            } else if let destination = navVC.topViewController as? DeviceWifiListViewController {
                guard let storeTemp = store else {return}
                destination.device = addedDevice
                destination.store = storeTemp
            }
        }
    }
    
}

// MARK: UICollectionViewDataSource

extension DevicesCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // this will always be 1, for now
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return devices.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DeviceCollectionViewCell

        if devices[indexPath.row].name == "newDeviceCollectionViewCell" {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newDeviceCollectionViewCell", for: indexPath) as? AddNewDeviceCollectionViewCell
            return cell!
        }
        
        cell?.deviceNameLabel.text = devices[indexPath.row].name
        
        cell?.previewImageView.load(urlString: devices[indexPath.row].thumbnailLink!)
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(devices[indexPath.row].name == "newDeviceCollectionViewCell"){
            // UNCOMMENT THIS WHEN YOU WANT TO SEND USER TO CONNECT TO A DEVICE
            self.performSegue(withIdentifier: "goToDeviceSetup", sender: nil)
            
            // COMMENT THIS OUT WHEN YOU DONT NEED IT ANYMORE
            getDeviceNameFromUser()
            
        } else {
            selectedDevice = devices[indexPath.row]
            performSegue(withIdentifier: "fromDevicesToSettings", sender: nil)
        }
    }
    
    func getDeviceNameFromUser(){
        // add new device
        let alertVC = UIAlertController(title: "New Device", message: "Provide the new device's name", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.autocapitalizationType = UITextAutocapitalizationType.words
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
                    
                    self.addDevice(name: deviceNameTextField.text!)
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
    
    
    @IBAction func unwindToDevices(segue:UIStoryboardSegue) {
        collectionView?.reloadData()
    }
}

extension DevicesCollectionViewController: storeSelectionDelegate {
    func storeSelected(_ store: Store) {
        self.store = store
        self.getDevices()
    }
}

extension DevicesCollectionViewController: DeviceDeleted {
    func deleteDevice(device: Device) {
        for int in 0...devices.count - 1 {
            if (devices[int]._id == device._id){
                devices.remove(at: int)
                let indexPath = IndexPath(row: int, section: 0)
                collectionView?.deleteItems(at: [indexPath])
                // TODO:- REMOVE DEVICE FROM ACTUAL SERVER
                
                return
            }
        }
    }
}

extension UIImageView {
    func load(urlString: String) {
        
        if let url = URL(string:urlString){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
        } else {
            self.image = UIImage(named: "novideo")
        }
    }
}
