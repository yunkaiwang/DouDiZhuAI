//
//  JokerCard.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class JokerCard: Card {
    private var type: JokerType
    
    init(type: JokerType) {
        self.type = type
        super.init(identifier: type.rawValue)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func isRedJoker()->Bool {
        return self.type == JokerType.red
    }
    
    func isBlackJoker()->Bool {
        return self.type == JokerType.black
    }
    
    public override func getRank() -> Int {
        return isRedJoker() ? 15 : 14
    }
    
    static func < (lhs: JokerCard, rhs: JokerCard) -> Bool {
        return lhs.isBlackJoker()
    }
    
    static func == (lhs: JokerCard, rhs: JokerCard) -> Bool {
        return lhs.getIdentifier() == rhs.getIdentifier()
    }
    
    static func > (lhs: JokerCard, rhs: JokerCard) -> Bool {
        return lhs.isRedJoker()
    }
}
