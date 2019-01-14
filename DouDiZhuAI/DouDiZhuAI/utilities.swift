//
//  utilities.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

func suitPriority(suit:String)->Int {
    if suit == "spades" {
        return 4
    } else if suit == "hearts" {
        return 3
    } else if suit == "clubs" {
        return 2
    } else {
        return 1
    }
}

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            self.swapAt(i, j)
        }
    }
    
    mutating func sort() {
        if count < 2 { return }
        
        for i in 0..<(count - 1) {
            for j in i+1..<(count) {
                if self[i] is JokerCard && self[j] is JokerCard  {
                    let card1 = self[i] as! JokerCard
                    if card1.isBlackJoker() {
                        self.swapAt(i, j)
                    }
                } else if self[i] is JokerCard {
                    continue
                } else if self[j] is JokerCard {
                    self.swapAt(i, j)
                } else {
                    let card1 = self[i] as! NumCard
                    let card2 = self[j] as! NumCard
                    
                    if card1.getNum() == card2.getNum() {
                        if suitPriority(suit: card2.getSuit()) > suitPriority(suit: card1.getSuit()) {
                            self.swapAt(i, j)
                        }
                    } else {
                        if card2.getNum() < 3 && card1.getNum() > 2 {
                            self.swapAt(i, j)
                        } else if card2.getNum() < 3 && card1.getNum() < 3 && card2.getNum() > card1.getNum() {
                            self.swapAt(i, j)
                        } else if card1.getNum() > 2 && card1.getNum() > 2 && card2.getNum() > card1.getNum() {
                            self.swapAt(i, j)
                        }
                    }
                }
            }
        }
    }
}
