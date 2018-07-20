//
//  MainSplitViewController.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/22/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController:UIViewController) -> UIViewController? {
        var is_detail = false
        if let nav = primaryViewController as? UINavigationController {
            if let nav2 = nav.topViewController as? UINavigationController {
                if nav2.topViewController is StoreViewController {
                    is_detail = true
                }
            }
        }
        if is_detail {
            return nil
        } else {
            let storyboard = UIStoryboard(name: "masterTV", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "detailCV")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
