//
//  Card.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class Card: Comparable, Codable {
    private var identifier: String = ""
    
    init(identifier:String) {
        self.identifier = identifier
    }
    
    func getIdentifier()->String {
        return self.identifier
    }
    
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs is NullCard {
            return true
        } else if rhs is NullCard {
            return false
        }
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
        if lhs is NullCard || rhs is NullCard {
            return false
        }
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
        if lhs is NullCard {
            return false
        } else if rhs is NullCard {
            return true
        }
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
