//
//  Card.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

class Card {
    private var identifier: String = ""
    
    init(identifier:String) {
        self.identifier = identifier
    }
    
    func getIdentifier()->String {
        return self.identifier
    }
    
}
