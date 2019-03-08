//
//  JokerType.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

enum JokerType: String {
    case black = "black_joker"
    case red = "red_joker"
    
    public static func fromString(s: String) -> JokerType {
        if s == "black_joker" {
            return .black
        } else {
            return .red
        }
    }
}

