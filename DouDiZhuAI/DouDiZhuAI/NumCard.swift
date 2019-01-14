//
//  NumCard.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

class NumCard: Card {
    private var suit: String = ""
    private var num: Int = 0
    
    init(suit: String, num: Int) {
        self.suit = suit
        self.num = num
        let identifier = String(num) + "_of_" + suit
        let texture = SKTexture(imageNamed: identifier)
        super.init(identifier: identifier, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getNum()->Int {
        return self.num
    }
    
    func getSuit()->String {
        return self.suit
    }
}
