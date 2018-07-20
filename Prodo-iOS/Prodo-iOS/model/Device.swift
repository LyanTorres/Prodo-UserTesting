//
//  Device.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/13/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import Foundation

struct Device: Codable {
    let _id: String
    let name: String
    let contentLinks: String?
    let thumbnailLink: String?
}
