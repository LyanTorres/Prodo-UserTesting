//
//  NewVideoFromViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/21/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class NewVideoFromViewController: UIViewController {

    
    var device: Device?
    var store: Store?
    var cardComp: CardCompositionCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (cardComp != nil) {
            performSegue(withIdentifier: "goToSelectTemplate", sender: "AddBlank")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func blankTemplateWasPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toVideoEditorFromCreateNewVideo", sender: sender)
    }
    
    @IBAction func fromTemplateWasPressed(_ sender: Any) {
         performSegue(withIdentifier: "goToSelectTemplate", sender: sender)
    }
    
    @IBAction func cancelWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToDeviceSettingsFromTemplates", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? SelectTemplateCollectionViewController {
            guard let storeTemp = store, let deviceTemp = device else {return}
            destination.device = deviceTemp
            destination.store = storeTemp
        }
        
        if let string = sender as? String {
            if(string == "AddBlank") {
                if let destination = segue.destination as? SelectTemplateCollectionViewController {
                    destination.cardComp = cardComp
                    destination.device = device!
                    destination.store = store!
                }
            }
        }
    }
    
    
}
