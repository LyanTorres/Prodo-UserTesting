//
//  DeviceSettingsViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
import CoreData

protocol DeviceDeleted {
    func deleteDevice(device: Device)
}

class DeviceSettingsViewController: UIViewController {
    
    @IBOutlet weak var videoPreviewImageView: UIImageView!
    @IBOutlet weak var playVideoSwitch: UISwitch!
    @IBOutlet weak var videoWilPlaySwitch: UISwitch!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var createNewVideoButton: UIButton!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var device: Device?
    var store: Store?
    var savedComposition: CardComposition?
    
    var delegate: DeviceDeleted!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    @IBAction func videoWillPlayHasChnged(_ sender: Any) {
        // TODO:- Update whether or not the video is playing and save the changes
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotToSelectTemplateFromSettings" {
            let nav = segue.destination as? UINavigationController
            let destination = nav?.topViewController as? SelectTemplateCollectionViewController
            destination?.device = device
            destination?.store = store
        }
        
        if segue.identifier == "gotToVideoEditorWithOldVideo" {
            if let destination = segue.destination as? BaseViewController {
                if let savedComposition = savedComposition {
                    destination.composition = savedComposition
                    destination.device = device
                    destination.store = store
                }
            }
        }
    }
    
    func updateUI(){
        editButton.isHidden = true
        if let deviceTemp = device{
            titleBar.title = "Manage: \(deviceTemp.name)"
            // TODO:- UNCOMMENT THIS WHEN IMPLEMENTED IN DATABASE AND DATA MODEL vvv
            lastUpdatedLabel.text = "Not available"
        }
        
        do {
            guard let preview = device?.thumbnailLink, let url = URL(string: preview) else {return}
            let data = try Data(contentsOf: url)
            videoPreviewImageView.image = UIImage(data: data)
            
            let request = NSFetchRequest<NSManagedObject>(entityName: "DeviceSaved")
            if request != nil {
                editButton.isHidden = false
            }
        }
        catch {
        }
    }
    
    @IBAction func createNewVideoWasPressed(_ sender: Any) {
       performSegue(withIdentifier: "gotToSelectTemplateFromSettings", sender: nil)
    }
    
    @IBAction func editWasPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "DeviceSaved")
        request.predicate = NSPredicate(format: "id = %@", (device?._id)!)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            print(result)
            if result.count == 1 {
                print("1")
                let objectUpdate = result[0]
                guard let compositionPath = objectUpdate.value(forKey: "compositionPath") as? String else { return }
                
                print(compositionPath)
                if let composition = NSKeyedUnarchiver.unarchiveObject(withFile: compositionPath) as? CardComposition {
                    print("comp")
                    self.savedComposition = composition
                    performSegue(withIdentifier: "gotToVideoEditorWithOldVideo", sender: nil)
                }
                
            }
        } catch {
            print("Failed")
        }
    }
    
    
    @IBAction func deleteDevice(_ sender: Any) {
        
        guard let deviceTemp = device else {return}
        let alertVC = UIAlertController(title: "Deleting device", message: "Are you sure you want to erase the device \(deviceTemp.name)", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "DELETE", style: .destructive, handler: {
            (alert) -> Void in
            
            if (self.delegate != nil) {
              //  self.delegate.deleteDevice(device: self.device!)
                URLSessionHelper.apiWithAuth(url: "/device/\((self.device?._id)!)", user: User.currentUser()!, methodType: "DELETE", body: nil, completion: { (res) in
                })
                self.dismiss(animated: true, completion: nil)
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert) -> Void in
            print("user cancelled deleting device")
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
    
    @IBAction func unwindBackToDevicesCollectionViewController(_ sender: Any) {
        performSegue(withIdentifier: "backToDevicesFromSettings", sender: nil)
    }
    
    @IBAction func unwindToDeviceSettings(segue:UIStoryboardSegue) {
        updateUI()
    }
    

    
}
