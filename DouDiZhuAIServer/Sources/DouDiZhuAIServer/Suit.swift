//
//  Suit.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class Suit: Comparable, Codable {
    static let suitPriority = [
        SuitType.spades: 4,
        SuitType.hearts: 3,
        SuitType.clubs: 2,
        SuitType.diamonds: 1,
        ]
    
    private var suit: SuitType
    
    init(type: SuitType) {
        self.suit = type
    }
    
    private func getSuitType() -> SuitType {
        return self.suit
    }
    
    public func getSuit() -> String {
        return self.suit.rawValue
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
