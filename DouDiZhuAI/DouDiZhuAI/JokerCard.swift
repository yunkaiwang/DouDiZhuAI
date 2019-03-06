//
//  JokerCard.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

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
