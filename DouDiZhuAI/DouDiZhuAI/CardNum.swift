//
//  CardNum.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-27.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class CardNum: Comparable, Hashable, Codable {
    private var num:Int;
    public static let max = CardNum(num: 2)
    public static let min = CardNum(num: 3)
    public static let numRank = [
        2: 13, 1: 12, 13: 11, 12: 10,
        11: 9, 10: 8, 9: 7, 8: 6, 7: 5,
        6: 4, 5: 3, 4: 2, 3: 1
    ]
    
    var hashValue: Int {
        return num.hashValue
    }
    
    init() {
        self.num = -1
    }
    
    init(num:Int) {
        self.num = num
    }
    
    func getNum()->Int {
        return self.num
    }
    
    func getRank() -> Int {
        return CardNum.numRank[self.num] ?? 0
    }
    
    static func < (lhs: CardNum, rhs: CardNum) -> Bool {
        let l = lhs.getNum(), r = rhs.getNum()
        if l > 2 {
            if r > 2 {
                return l < r
            } else {
                return true
            }
        } else {
            if r > 2 {
                return false
            } else {
                return l < r
            }
        }
    }
    
    static func == (lhs: CardNum, rhs: CardNum) -> Bool {
        return lhs.getNum() == rhs.getNum()
    }
    
    static func == (lhs:CardNum, rhs: Int) -> Bool {
        return lhs.getNum() == rhs
    }
    
    static func != (lhs:CardNum, rhs: Int) -> Bool {
        return lhs.getNum() != rhs
    }
    
    static func - (lhs: CardNum, rhs: CardNum) -> Int {
        if lhs < rhs {
            return -1
        } else {
            if lhs.getNum() < 2 {
                return 15 - rhs.getNum()
            } else {
                return lhs.getNum() - rhs.getNum() + 1
            }
        }
    }
    
    static func > (lhs: CardNum, rhs: CardNum) -> Bool {
        let l = lhs.getNum(), r = rhs.getNum()
        if l > 2 {
            if r > 2 {
                return l > r
            } else {
                return false
            }
        } else {
            if r > 2 {
                return true
            } else {
                return l > r
            }
        }
    }
}
