//
//  AssetsCollectionViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

private let reuseIdentifier = "asset_cell"
private let reuseIdentifierHeader = "asset_header"

protocol AssetDelegate: class  {
    func addedAsset(asset: Asset)
}

class AssetsCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var assets: [[Asset]] = [[], [], [], [], [], []]
    var sectionNames = ["Text", "Decorative", "Drinks", "Foods", "Desserts", "Emojis"]
    var deleagte: AssetDelegate!
    weak var delegate:AssetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateAssets()
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    // MARK: UICollectionViewDataSource

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    func generateAssets() {
        let textAssets = ["H1"]
        
        let decorativeAssets = ["big bow", "big red bow", "blue sparkles", "chef hat", "cooking", "falling stars", "flags", "garlands", "heart ballons", "lights", "megaphone loud", "megaphone low", "orange megaphone", "party ballons", "plate", "shining", "sparkles"]
        
        let drinkAssets = ["cocktail", "coffee", "hot coffee", "off brand pepsi", "pint", "soda can", "soda", "tea-cup white", "tea-cup", "toast", "water", "wine-glass"]
        
        let foodAssets = ["bacon","bread", "chicken-leg", "chinese-food", "dinner", "fast-food", "full break fast", "rice", "roast-chicken", "sandwich", "small break fast", "sub", "waffle"]
        
        let dessertAssets = ["chocolate","cookie crumbles", "cookie", "cupcake", "donut", "ice-cream bowl", "ice-cream cone with cherry", "ice-cream cup", "ice-cream", "piece-of-cake", "popsicle", "red popsicle", "sweet"]
        let emojiAssets = ["cool", "embarrassed", "happy laugh", "happy smile", "happy", "in-love", "tongue-out", "unhappy"]
        
        createTextAssetsFromArray(array: textAssets)
        createIconAssetsFromArray(array: decorativeAssets, section: 1)
        createIconAssetsFromArray(array: drinkAssets, section: 2)
        createIconAssetsFromArray(array: foodAssets, section: 3)
        createIconAssetsFromArray(array: dessertAssets, section: 4)
        createIconAssetsFromArray(array: emojiAssets, section: 5)
    }
    
    func createTextAssetsFromArray(array: [String]){
        for item in array {
            assets[0].append(Text(frame: CGRect(x: 0, y: 0, width: 100, height: 50), name: item, text: "TEXT", previewImage: UIImage(named: item)!))
        }
    }
    
    func createIconAssetsFromArray(array: [String], section: Int){
        for item in array{
            assets[section].append(Icon(frame: CGRect(x: 0, y: 0, width: 100, height: 100), name: item, image: UIImage(named: item)!))
        }
    }
    
}

extension AssetsCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return assets.count
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return assets[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "asset_cell", for: indexPath) as? AssetCollectionViewCell
        
        cell?.image = assets[indexPath.section][indexPath.row].previewImage
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.addedAsset(asset: assets[indexPath.section][indexPath.row].copy() as! Asset)
        print("hello")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as? AssetHeaderCollectionReusableView
        header?.headerLabel.text = sectionNames[indexPath.section]
        return header!
    }
}
