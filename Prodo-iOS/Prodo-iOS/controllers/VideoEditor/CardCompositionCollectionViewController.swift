//
//  CardCompositionCollectionViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CardCollectionViewCell"

protocol CardCompositionDelegate {
    func selectedCard(card: Card)
}

class CardCompositionCollectionViewController: UICollectionViewController {

    var delegate: CardCompositionDelegate!
    var delegateForAddCard: AddCard!
    var device: Device?
    var store: Store?
    var indexPathForInsert: IndexPath?
    var composition: CardComposition?
    var selectedCard: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composition?.editorWindowSize = CGSize(width: 699, height: 394);

        if let card = composition?.cards[0] {
            selectedCard = card
            delegate.selectedCard(card: card)
            collectionView?.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let cell = collectionView!.cellForItem(at: IndexPath(item: 0, section: 0))
        cell?.isSelected = true
    }

    @IBAction func Publish(_ sender: Any ) {
        self.performSegue(withIdentifier: "editor", sender: nil)
    }

    @IBAction func addWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToTemplatesFromVideoEditor", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToTemplatesFromVideoEditor") {
            let controller = (segue.destination as! UINavigationController).topViewController as! SelectTemplateCollectionViewController
            controller.cardComp = self
        }
        if (segue.identifier == "editor"){
            let destination = segue.destination as? ExporterViewController
            let video = VideoGenerator(with: composition!)
            video.delegate = destination
            video.StartProcess(forDeviceID: (device?._id)!) { (url) in
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (composition?.cards.count)!
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CardCollectionViewCell
        
        if composition?.cards[indexPath.row].backgroundImage == #imageLiteral(resourceName: "transition") {
            let transitionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "transition_cell", for: indexPath) as? TransitionCollectionViewCell
            transitionCell?.imageBackgroundView.layer.cornerRadius = 5
            transitionCell?.transitionImageView.image = #imageLiteral(resourceName: "transition")
            return transitionCell!
        } else {
            cell?.image = composition?.cards[indexPath.row].thumnail
        }
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if composition?.cards[indexPath.row].backgroundImage != #imageLiteral(resourceName: "transition"){
            delegate.selectedCard(card: (composition?.cards[indexPath.row])!)
            selectedCard = (composition?.cards[indexPath.row])!
        } else {
            performSegue(withIdentifier: "showTransitions", sender: nil)
        }
    }
    
    func updateCardPreview(card: UIImageView, image: UIImage) {
        card.image = image
    }
    

}

extension CardCompositionCollectionViewController: AddCard {
    
    func addedCard(card: Card) {
        composition?.transition.append("")
        composition?.cards.append(Card(assets: [], background: #imageLiteral(resourceName: "transition")))
        composition?.cards.append(card)
        collectionView?.reloadData()
    }
    
    func animateAddCard(){
        let indexPath = IndexPath(item: (self.composition?.cards.count)! - 1, section: 0)
        collectionView?.performBatchUpdates( { self.collectionView?.insertItems(at: [indexPath]) }, completion: nil)
    }
}

extension CardCompositionCollectionViewController: EditorDelegate {
    func addedAsset(asset: Asset) {
        
    }
    
    func selectedAsset(asset: Asset) {
        
    }
    
    func generatedThumnail() {
          print("hello=------------ouhouhououb----")
          self.collectionView?.reloadData()
    }
}

extension CardCompositionCollectionViewController: CompositionDelegate {
    func getComposition() -> CardComposition {
        return composition!
    }
}

extension CardCompositionCollectionViewController: AssetPropertyDelegate{
    func deleted(asset: Asset) {
        for (index,item) in (selectedCard?.assets.enumerated())! {
            if item === asset {
                selectedCard?.assets.remove(at: index)
                delegate.selectedCard(card: selectedCard!)
            }
        }
     }
    
    
}


