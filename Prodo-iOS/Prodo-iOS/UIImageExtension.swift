//
//  UIImageExtension.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/30/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
extension UIImage{
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
