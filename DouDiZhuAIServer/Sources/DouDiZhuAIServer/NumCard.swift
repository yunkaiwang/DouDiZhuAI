//
//  NumCard.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class NumCard: Card {
    private let suit: Suit
    private let num: CardNum
    
    init(suit: Suit, num: Int) {
        self.suit = suit
        self.num = CardNum(num: num)
        let identifier = String(num) + "_of_" + suit.getSuit()
        super.init(identifier: identifier)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func getNum()->CardNum {
        return self.num
    }
    
    public func getSuit() -> Suit {
        return self.suit
    }
    
    public func getRank() -> Int {
        return self.num.getRank()
    }
    
    static func < (lhs: NumCard, rhs: NumCard) -> Bool {
        if lhs.getNum() == rhs.getNum() {
            return lhs.getSuit() < rhs.getSuit()
        }
        return lhs.getNum() < rhs.getNum()
    }
    
    static func == (lhs: NumCard, rhs: NumCard) -> Bool {
        return lhs.getNum() == rhs.getNum() && lhs.getSuit() == rhs.getSuit()
    }
    
    static func > (lhs: NumCard, rhs: NumCard) -> Bool {
        if lhs.getNum() == rhs.getNum() {
            return lhs.getSuit() > rhs.getSuit()
        }
        return lhs.getNum() > rhs.getNum()
    }
}
