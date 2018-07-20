//
//  AssetPropertiesTableViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

protocol AssetPropertyDelegate {
    func deleted(asset: Asset)
}

class AssetPropertiesTableViewController: UITableViewController {
    
    let textPropertiesArray = ["font_cell","color_cell","size_cell","alpha_cell", "delete_cell"]
    let iconPropertiesArray = [ "alpha_cell", "delete_cell"]
    var propertiesArray = [""]
    var assetSelected: Asset?
    var assetIndex: Int?
    var isEdditingFont: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var delegate: AssetPropertyDelegate!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let asset = assetSelected else { return 0 }
        guard let _ = asset as? Text else {propertiesArray = iconPropertiesArray ; return propertiesArray.count}
        propertiesArray = textPropertiesArray
        return propertiesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: propertiesArray[indexPath.row], for: indexPath)
        
        if let cell = cell as? AlphaUITableViewCell {
            cell.alphaSlider.value = Float((assetSelected?.alpha)!)
            cell.alphaSlider.addTarget(self, action: #selector(alphaChange(sender:)), for: .valueChanged)
        }
        
        if let cell = cell as? SizeTableViewCell {
            if let assetSelected = assetSelected as? Text {
                cell.sizeLabel.text = assetSelected.font.pointSize.description
                cell.stepper.addTarget(self, action: #selector(fontSize(sender:)), for: .valueChanged)
            }
        }
        
        if let cell = cell as? FontTableViewCell {
             if let assetSelected = assetSelected as? Text {
                cell.fontlabel.text = assetSelected.font.fontName
            }
        }
        
        if let cellAnimated = cell as? AnimatedTableViewCell {
            cellAnimated.isAnimatedSwitch.isOn = false
            return cellAnimated
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (propertiesArray[indexPath.row]) {
        case "font_cell":
            performSegue(withIdentifier: "list_segue", sender: self)
            isEdditingFont = true
        case "color_cell":
            performSegue(withIdentifier: "list_segue", sender: self)
            isEdditingFont = false
        case "delete_cell":
            delegate.deleted(asset: assetSelected!)
            assetSelected = nil
            self.tableView.reloadData()
        default:
            deleteAsset()
            break
        }
    }
    
    @objc func alphaChange(sender: UISlider) {
        assetSelected?.alpha = CGFloat(sender.value)
    }
    
    @objc func fontSize(sender: UIStepper) {
        if let assetSelected = assetSelected as? Text {
            let font = assetSelected.font.withSize(CGFloat(sender.value))
            print(font)
            assetSelected.font = font
        }
    }
    
    func chooseSize() {
        
    }
    
    func chooseColor() {
        
    }
    
    func isAnimated(){
        
    }
    
    func deleteAsset(){
        // should prob implement delegate to tell the editr to delete this asset
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "list_segue") {
            let des = segue.destination as? PropertyListTableViewController
            des?.delegate = self
            des?.isEditingFont = isEdditingFont
        }
    }

}

extension AssetPropertiesTableViewController: PropertyListDelegate {
    func textColor(color: UIColor) {
        if let assetSelected = assetSelected as? Text {
            assetSelected.textLabel.textColor = color
        }
    }
    
    func fontSlected(font: UIFont) {
        if let assetSelected = assetSelected as? Text {
            assetSelected.font = font.withSize(assetSelected.font.pointSize)
        }
    }
}

extension AssetPropertiesTableViewController: EditorDelegate  {
    func addedAsset(asset: Asset) {
        
    }
    
    func generatedThumnail() {
        print("asset --------------")
    }
    
    func selectedAsset(asset: Asset) {
        self.assetSelected = asset
        self.tableView.reloadData()
    }
    
}
