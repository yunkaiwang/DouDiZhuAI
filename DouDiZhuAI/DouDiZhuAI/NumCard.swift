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
    private var num: CardNum = CardNum()
    
    init(suit: String, num: Int) {
        self.suit = suit
        self.num = CardNum(num: num)
        let identifier = String(num) + "_of_" + suit
        super.init(identifier: identifier)
    }
    
    func getNum()->CardNum {
        return self.num
    }
    
    func getSuit()->String {
        return self.suit
    }
    
    static func < (lhs: NumCard, rhs: NumCard) -> Bool {
        return lhs.getNum() < rhs.getNum()
    }
    
    static func == (lhs: NumCard, rhs: NumCard) -> Bool {
        return lhs.getNum() == rhs.getNum()
    }
    
    static func > (lhs: NumCard, rhs: NumCard) -> Bool {
        return lhs.getNum() > rhs.getNum()
    }
}
