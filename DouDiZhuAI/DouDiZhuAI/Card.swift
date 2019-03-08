//
//  Card.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

public class Card: Comparable, Codable {
    private var identifier: String = ""
    
    init(identifier:String) {
        self.identifier = identifier
    }
    
    func getIdentifier()->String {
        return self.identifier
    }
    
    public static func identifierToCard(id: String) -> Card {
        if id.isEmpty {
            return NullCard.shared
        } else if id.contains("joker") {
            return JokerCard(type: JokerType.fromString(s: id))
        } else {
            return NumCard(suit: Suit(type: SuitType.fromString(s: String(id[id.index(id.lastIndex(of: "_")!, offsetBy: 1)...]))), num: Int(id.prefix(upTo: id.firstIndex(of: "_")!))!)
        }
    }
    
    public static func < (lhs: Card, rhs: Card) -> Bool {
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
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
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
    
    public static func > (lhs: Card, rhs: Card) -> Bool {
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
