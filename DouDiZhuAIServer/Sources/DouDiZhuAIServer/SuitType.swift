//
//  SuitType.swift
//
//  Created by yunkai wang on 2019-03-04.
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
