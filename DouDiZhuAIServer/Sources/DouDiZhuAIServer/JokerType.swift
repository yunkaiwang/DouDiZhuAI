//
//  JokerType.swift
//
//  Created by yunkai wang on 2019-03-04.
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
