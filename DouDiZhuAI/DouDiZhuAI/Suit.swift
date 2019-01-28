//
//  Suit.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-27.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

enum SuitType {
    case spades
    case hearts
    case diamonds
    case clubs
}

class Suit: Comparable {
    static var suitPriority = [
        SuitType.spades: 4,
        SuitType.hearts: 3,
        SuitType.clubs: 2,
        SuitType.diamonds: 1,
    ]
    
    private var suit: SuitType
    private var identifier: String
    
    init(type: SuitType) {
        self.suit = type
        switch self.suit {
        case .spades:
            self.identifier = "spades"
        case .hearts:
            self.identifier = "hearts"
        case .diamonds:
            self.identifier = "diamonds"
        default:
            self.identifier = "clubs"
        }
    }
    
    func getSuit() -> String {
        return self.identifier
    }
    
    private func getSuitType() -> SuitType {
        return self.suit
    }
    
    static func < (lhs: Suit, rhs: Suit) -> Bool {
        return suitPriority[lhs.getSuitType()]! < suitPriority[rhs.getSuitType()]!
    }
    
    static func == (lhs: Suit, rhs: Suit) -> Bool {
        return suitPriority[lhs.getSuitType()]! == suitPriority[rhs.getSuitType()]!
    }
    
    static func > (lhs: Suit, rhs: Suit) -> Bool {
        return suitPriority[lhs.getSuitType()]! > suitPriority[rhs.getSuitType()]!
    }
}
