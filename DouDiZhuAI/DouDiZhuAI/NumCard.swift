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
    private var suit: Suit
    private var num: CardNum
    
    init(suit: Suit, num: Int) {
        self.suit = suit
        self.num = CardNum(num: num)
        let identifier = String(num) + "_of_" + suit.getSuit()
        super.init(identifier: identifier)
    }
    
    func getNum()->CardNum {
        return self.num
    }
    
    private func getSuit() -> Suit {
        return self.suit
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
