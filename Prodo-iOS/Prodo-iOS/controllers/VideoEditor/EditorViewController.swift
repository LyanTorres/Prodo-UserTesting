//
//  EditorViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
import AlertOnboarding
import CoreData

protocol EditorDelegate {
    func addedAsset(asset: Asset)
    func generatedThumnail()
    func selectedAsset(asset: Asset)
}
//
//extension EditorDelegate {
//    func generatedThumnail() {
//        print("hello")
//    }
//    func addedAsset(asset: Asset) {
//
//    }
//}

protocol CompositionDelegate {
 func getComposition() -> CardComposition
}

class EditorViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var assetText: UITextField?
    var card: Card?
    var textAssetChange: Text?
    var selectedAsset: Asset?
    var device: Device?
    
    // ONBOARDING
    var arrayOfImage = ["video_editor", "cardreel", "card", "assets"]
    var arrayOfTitle = ["THIS IS THE VIDEO EDITOR", "CARD REEL", "CARDS", "ASSETS"]
    var arrayOfDescription = ["This is where you will be creating your digital content! Here's a quick little tour of need to know things.",
                              "Your card reel holds each screen of your video which are called \"cards\". Each card represents 12 seconds in your video. In here you can change the order of cards and choose a different transition between different cards.",
                              "The cards in your card reel hold assets. The selected card will be previewed in the editor, allowing you to move your assets around and design it as you please!", "Assets are icons, texts, images you upload, basically anything that you place inside a card. You can change the properties of them in the properties panel. located below the assets panel."]
    
    var alertView = AlertOnboarding()

    var delegate: EditorDelegate!
    var compositionDelegate: CompositionDelegate!
    
    @IBOutlet weak var editorPreviewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.isMultipleTouchEnabled = true
        playerView.layer.masksToBounds = true
        
        if let cardTemp = card {
            backgroundImage.image = cardTemp.backgroundImage
        }
        
        let defaults = UserDefaults.standard
        let isFirstTimeUsingVideoEditor = defaults.bool(forKey: "FirstTimeUsingVideoEditor")
        
        if(isFirstTimeUsingVideoEditor) {
            UserDefaults.standard.set(false, forKey: "FirstTimeUsingVideoEditor")
            alertView.delegate = self as AlertOnboardingDelegate
            alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
            setUpOnBoarding()
            alertView.show()
        }
    }
    
    func generateThumnail()  {
        card?.thumnail = UIImage.init(view: playerView)
        delegate.generatedThumnail()
        print("hello----------------------------")
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view as? Asset else { return }
        if let seletectAsset = selectedAsset {
            seletectAsset.isSelected = false
        }
        selectedAsset = view
        view.isSelected = true
        delegate.selectedAsset(asset: view)
        self.view.bringSubview(toFront: view)
        let translation = sender.translation(in: self.playerView)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        generateThumnail()
    }
    
    @objc func pinchView(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view as? Asset else { return }
        if let seletectAsset = selectedAsset {
            seletectAsset.isSelected = false
        }
        selectedAsset = view
        view.isSelected = true
        view.transform = CGAffineTransform(scaleX: sender.scale,y: sender.scale)
        delegate.selectedAsset(asset: view)
        generateThumnail()
    }
    

    @objc func editText(_ sender: UITapGestureRecognizer) {
        textAssetChange = sender.view as? Text
        let alert = UIAlertController(title: "Change text", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            self.textAssetChange?.text = textField.text!
            textField.text = self.textAssetChange?.text
        }
        alert.addTextField { (textField) in
            textField.text = self.textAssetChange?.text
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated:true, completion: nil)
    }
    
    @objc func oneTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? Asset else { return }
        if let seletectAsset = selectedAsset {
            seletectAsset.isSelected = false
        }
        view.isSelected = true
        selectedAsset = view
        delegate.selectedAsset(asset: view)
    }
    
    func containsGestureRecognizer(recognizers: [UIGestureRecognizer]?, find: UIGestureRecognizer) -> Bool {
        if let recognizers = recognizers {
            for gr in recognizers {
                if gr == find {
                    return true
                }
            }
        }
        return false
    }
    
    //remove all the assets on screen and replace them with the current card assets.
    func ReloadView() {
        backgroundImage.image = card?.backgroundImage
        playerView.subviews.forEach {
            if $0 .isKind(of: Asset.self) {
                $0.removeFromSuperview()
            }
        }
        for asset in (card?.assets)! {
            print(asset.frame)
            playerView.addSubview(asset)
            
            if asset is Text {
                let twoTaps = UITapGestureRecognizer(target: self, action:  #selector(editText(_:)))
                guard containsGestureRecognizer(recognizers: asset.gestureRecognizers, find: twoTaps) == false else { return }
                twoTaps.numberOfTapsRequired = 2
                asset.isUserInteractionEnabled = true
                asset.addGestureRecognizer(twoTaps)
            }
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
            guard containsGestureRecognizer(recognizers: asset.gestureRecognizers, find: panGesture) == false else { return }
            asset.isUserInteractionEnabled = true
            asset.addGestureRecognizer(panGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:)))
            guard containsGestureRecognizer(recognizers: asset.gestureRecognizers, find: pinchGesture) == false else { return }
            asset.addGestureRecognizer(pinchGesture)
            
            let oneTap = UITapGestureRecognizer(target: self, action:  #selector(oneTap(_:)))
            guard containsGestureRecognizer(recognizers: asset.gestureRecognizers, find: oneTap) == false else { return }
            asset.addGestureRecognizer(oneTap)
            playerView.addSubview(asset)
        }
    }
    
    @IBAction func cancelWasPressed(_ sender: Any) {
        
        let alertVC = UIAlertController(title: "Save", message: "Do you want to save this?", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "No", style: .destructive, handler: {
            (alert) -> Void in
              self.performSegue(withIdentifier: "unwindToDeviceSettingsFromEditor", sender: nil)
        })
        let cancelAction = UIAlertAction(title: "Save", style: .default, handler: {
            (alert) -> Void in
            self.saveToCoreData()
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "unwindToDeviceSettingsFromEditor", sender: nil)
        })
        alertVC.addAction(submitAction)
        alertVC.addAction(cancelAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
    func saveToCoreData() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fullPath = paths[0].appendingPathComponent((device?._id)!)
        let composition = compositionDelegate.getComposition()
        print(composition.cards[0].assets.count)
        NSKeyedArchiver.archiveRootObject(composition, toFile: fullPath.path)
        
        print(fullPath.path)
        if let composition = NSKeyedUnarchiver.unarchiveObject(withFile: fullPath.path) as? CardComposition {
            print(composition.cards.count)
        }
        else {
            print("no")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "DeviceSaved")
        request.predicate = NSPredicate(format: "id = %@", (device?._id)!)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let objectUpdate = result[0]
                objectUpdate.setValue(device?._id, forKey: "id")
                objectUpdate.setValue(fullPath.path, forKey: "compositionPath")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "DeviceSaved", in: context)
                let deviceToSave = NSManagedObject(entity: entity!, insertInto: context)
                deviceToSave.setValue(device?._id, forKey: "id")
                deviceToSave.setValue(fullPath.path, forKey: "compositionPath")
            }
        } catch {
            print("Failed")
        }

        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    
    }
}

extension EditorViewController: CardCompositionDelegate {
    func selectedCard(card: Card)  {
        self.card = card
        self.ReloadView()
    }
}

extension EditorViewController: AssetDelegate {
    func addedAsset(asset: Asset) {
        asset.location = CGRect(x: 0, y: 0, width: asset.frame.width, height: asset.frame.height)
        if let selectedCard = card {
            selectedCard.assets.append(asset)
        }
        
        if asset is Text {
            let twoTaps = UITapGestureRecognizer(target: self, action:  #selector(editText(_:)))
            twoTaps.numberOfTapsRequired = 2
            asset.isUserInteractionEnabled = true
            asset.addGestureRecognizer(twoTaps)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        asset.isUserInteractionEnabled = true
        asset.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:)))
        asset.addGestureRecognizer(pinchGesture)
        
        let oneTap = UITapGestureRecognizer(target: self, action:  #selector(oneTap(_:)))
        asset.addGestureRecognizer(oneTap)
        playerView.addSubview(asset)
    }
}

extension EditorViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvas
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func touchesShouldCancel(in view: UIView) -> Bool {
        print("touches")
        if view is Asset {
            return true
        }
        return false
    }
}

extension EditorViewController: AlertOnboardingDelegate{
    
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
        self.alertView.titleSkipButton = "PASS"
        self.alertView.titleGotItButton = "UNDERSTOOD !"
    }
}


