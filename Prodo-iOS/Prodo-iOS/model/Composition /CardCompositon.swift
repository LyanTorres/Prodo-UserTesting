//
//  CardCompositon.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class CardComposition: NSObject, NSCoding {
  
    var cards:[Card]
    var transition:[String]
    var editorWindowSize: CGSize!
    
    init(cards: [Card], transition: [String]) {
        self.cards = cards
        self.transition = transition
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let cards = decoder.decodeObject(forKey: "cards") as? [Card],
            let transitions = decoder.decodeObject(forKey: "transition") as? [String] else {return nil}
         self.init(cards: cards, transition: transitions)
      
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.cards, forKey: "cards")
        aCoder.encode(self.transition, forKey: "transition")
        aCoder.encode(self.editorWindowSize, forKey: "editorWindowSize")
    
    }
}
