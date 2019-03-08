//
//  NullCard.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-30.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class NullCard: Card {
    public static let shared = NullCard()
    
    private init() {
        super.init(identifier: "NULL")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
