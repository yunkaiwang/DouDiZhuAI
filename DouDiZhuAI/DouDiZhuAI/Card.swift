//
//  Card.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

class Card: SKSpriteNode {
    private var identifier: String = ""
    
    init(identifier:String, texture: SKTexture) {
        self.identifier = identifier
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getIdentifier()->String {
        return self.identifier
    }
}
