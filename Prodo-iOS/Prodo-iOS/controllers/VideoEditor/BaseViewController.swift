//
//  BaseViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var editorViewController: EditorViewController?
    var assetsViewController: AssetsCollectionViewController?
    var cardCompositionViewController: CardCompositionCollectionViewController?
    var assetPropertiesViewController: AssetPropertiesTableViewController?
    var composition: CardComposition?
    var device: Device?
    var store: Store?
    
    override func viewDidLoad() {
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "Assets") {
            let nav = segue.destination as? UINavigationController
            self.assetsViewController = nav?.topViewController as? AssetsCollectionViewController
        }
        
        if (segue.identifier == "Properties") {
            let nav = segue.destination as? UINavigationController
            self.assetPropertiesViewController = nav?.topViewController as? AssetPropertiesTableViewController
            print("Properties")
        }
        
        if (segue.identifier == "CardTimeline") {
            let nav = segue.destination as? UINavigationController
            self.cardCompositionViewController = nav?.topViewController as? CardCompositionCollectionViewController
            self.assetPropertiesViewController?.delegate = self.cardCompositionViewController
             if let composition = composition {
                self.cardCompositionViewController?.composition = composition
                self.cardCompositionViewController?.device = device
                self.cardCompositionViewController?.store = store
             }
        }
        
        if (segue.identifier == "Editor") {
            let nav = segue.destination as? UINavigationController
            self.editorViewController = nav?.topViewController as? EditorViewController
            self.editorViewController?.device = device
            self.assetsViewController?.delegate = self.editorViewController
            self.editorViewController?.delegate = self.cardCompositionViewController
            self.editorViewController?.delegate = self.assetPropertiesViewController
            self.editorViewController?.compositionDelegate = self.cardCompositionViewController
            self.cardCompositionViewController?.delegate = self.editorViewController
            if let cardTemp = composition?.cards[0] {
                self.editorViewController?.card = cardTemp
            }
            print("Editor")
        }
    }
}


