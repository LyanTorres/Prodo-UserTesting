//
//  PropertieListTableViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 7/12/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

protocol PropertyListDelegate {
    func fontSlected(font: UIFont)
    func textColor(color: UIColor)
}

class PropertyListTableViewController: UITableViewController {
   
    let fonts: [UIFont] = [UIFont(name: "ArialMT", size: 15)!,UIFont(name: "Helvetica", size: 15)!,UIFont(name: "Copperplate-Light", size: 15)!,UIFont(name: "Copperplate", size: 15)!,UIFont(name: "Copperplate-Bold", size: 15)!,UIFont(name: "KohinoorTelugu-Regular", size: 15)!,UIFont(name: "KohinoorTelugu-Medium", size: 15)!,UIFont(name: "KohinoorTelugu-Light", size: 15)!,UIFont(name: "Thonburi", size: 15)!,UIFont(name: "Thonburi-Bold", size: 15)!,UIFont(name: "Thonburi-Light", size: 15)!,UIFont(name: "CourierNewPS-BoldMT", size: 15)!]
    let color: [UIColor] = [UIColor.black,UIColor.blue,UIColor.blue,UIColor.brown,UIColor.cyan,UIColor.darkGray,UIColor.gray,UIColor.green,
                            UIColor.lightGray,UIColor.magenta,UIColor.orange,UIColor.purple,UIColor.red,UIColor.white,UIColor.yellow]
    
    var isEditingFont: Bool?
    
    var delegate: PropertyListDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
}

extension PropertyListTableViewController  {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEditingFont == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fontTitle_cell", for: indexPath)
            cell.textLabel?.text = fonts[indexPath.row].fontName
            cell.textLabel?.font = fonts[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "color_cell", for: indexPath) as? ColorTableViewCell
            cell?.colorLabel.text = color[indexPath.row].description
            cell?.corlorView.backgroundColor = color[indexPath.row]
            return cell!
        }
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if isEditingFont == true {
            delegate.fontSlected(font: fonts[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
         else {
            delegate.textColor(color: color[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
    }
}
