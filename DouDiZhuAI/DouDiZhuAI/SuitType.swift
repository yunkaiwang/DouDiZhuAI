//
//  SuitType.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-05.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

enum SuitType : String, Codable {
    case spades = "spades"
    case hearts = "hearts"
    case diamonds = "diamonds"
    case clubs = "clubs"
    
    public static func fromString(s: String) -> SuitType {
        if s == "spades" {
            return .spades
        } else if s == "hearts" {
            return .hearts
        } else if s == "diamonds" {
            return .diamonds
        } else {
            return .clubs
        }
    }
}
