//
//  SelectTemplateCollectionViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/21/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

private let reuseIdentifier = "template_cell"

protocol AddCard: class {
    func addedCard(card:Card)
}

class SelectTemplateCollectionViewController: UICollectionViewController {

    var templates = ["Black blank", "White blank","bagel close up", "chocolate surprise", "bakery goods", "pouring some beer", "bread surprise", "happy breakfast", "smoulder","peek-a-chicken", "coffee beans", "morning joe", "coffee lover", "second dinner", "refreshing drinks", "veggie ambush", "greens", "bucket of happiness", "meat and veggies","homemade pie","good looking rice","healthy salad","prepared salad","colorful foods","scrumptous soup","yogurt"]
    
    var delegate: AddCard!
    var selectedTemplate: Int?
    var device: Device?
    var store: Store?
    var cardComp: CardCompositionCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return templates.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTemplate = indexPath.row
        if cardComp != nil {
            if let int = selectedTemplate {
                let asset = [Asset]()
                if let image = UIImage(named: templates[int]){
                let card = Card(assets: [], background: image)
                delegate = cardComp
                delegate.addedCard(card: card)
                self.dismiss(animated: true, completion: nil)
                    
                }
            }
        } else {
            performSegue(withIdentifier: "gotToVideoEditorWithTemplate", sender: nil)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PreMadeTemplateCollectionViewCell
            cell?.previewImageView.image = UIImage(named: templates[indexPath.row])
            cell?.previewImageView.layer.cornerRadius = 5
            cell?.templateNameLabel.text = templates[indexPath.row]
            return cell!

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BaseViewController {
            // send any data you need to send
            if let int = selectedTemplate, let image = UIImage(named:templates[int]){
                let cards = [Card(assets: [], background: image)]
                print("------------------------------------")
                print(cards)
                destination.composition = CardComposition(cards: cards, transition: [])
                destination.device = device
                destination.store = store
            }
        }
    }
}
