//
//  CardNum.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class CardNum: Comparable, Hashable, Codable {
    private var num:Int;
    
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
