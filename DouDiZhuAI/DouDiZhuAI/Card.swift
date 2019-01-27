//
//  Card.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

class Card: Comparable {
    private var identifier: String = ""
    
    init(identifier:String) {
        self.identifier = identifier
    }
    
    func getIdentifier()->String {
        return self.identifier
    }
    
    static func < (lhs: Card, rhs: Card) -> Bool {
        if let card1 = lhs as? JokerCard {
            if let card2 = rhs as? JokerCard {
                return card1 < card2
            } else {
                return false
            }
        } else {
            if rhs is JokerCard {
                return true
            } else {
                let card1 = lhs as! NumCard
                let card2 = rhs as! NumCard
                return card1 < card2
            }
        }
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        if let card1 = lhs as? JokerCard {
            if let card2 = rhs as? JokerCard {
                return card1 == card2
            } else {
                return false
            }
        } else {
            if rhs is JokerCard {
                return false
            } else {
                let card1 = lhs as! NumCard
                let card2 = rhs as! NumCard
                return card1 == card2
            }
        }
    }
    
    static func > (lhs: Card, rhs: Card) -> Bool {
        if let card1 = lhs as? JokerCard {
            if let card2 = rhs as? JokerCard {
                return card1 > card2
            } else {
                return true
            }
        } else {
            if rhs is JokerCard {
                return false
            } else {
                let card1 = lhs as! NumCard
                let card2 = rhs as! NumCard
                return card1 > card2
            }
        }
    }
}
