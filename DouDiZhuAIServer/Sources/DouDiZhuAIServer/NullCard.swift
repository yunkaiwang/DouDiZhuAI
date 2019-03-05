//
//  NullCard.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class NullCard: Card {
    init() {
        super.init(identifier: "NULL")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
