//
//  JokerCard.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

class JokerCard: Card {
    
    private var type = JokerType.black
    
    init(type: JokerType) {
        self.type = type
        var identifier: String
        switch type {
        case .black:
            identifier = "black_joker"
        case .red:
            identifier = "red_joker"
        }
        super.init(identifier: identifier)
    }
    
    func isRedJoker()->Bool {
        return self.type == JokerType.red
    }
    
    func isBlackJoker()->Bool {
        return self.type == JokerType.black
    }
}
