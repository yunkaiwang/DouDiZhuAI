//
//  Player.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-18.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

public enum PlayerError: Error {
    case creationFailed
}

class Player {
    public let id: String
    private var cards: [Card]
//    private var playerNum: PlayerNum
    internal var beLandlord: Bool
    internal var pillageLandlord: Bool
    
    init(id: String) {
        self.id = id
        self.cards = []
//        self.playerNum = num
        self.beLandlord = false
        self.pillageLandlord = false
    }
    
    func getNumCard()->Int {
        return self.cards.count
    }
    
    func getCards()->[Card] {
        return self.cards
    }
    
    func startNewGame(cards: [Card]) {
        self.cards = cards
        self.beLandlord = false
        self.pillageLandlord = false
    }
    
    func addLandlordCard(newCards: [Card]) {
        self.cards += newCards
        self.cards.sort()
    }
    
    func pass() {
    }
    
    func wantToBeLandlord()->Bool {
        return self.beLandlord
    }
    
    func wantToPillageLandlord()->Bool {
        return self.pillageLandlord
    }
    
//    func getPlayerNum()->PlayerNum {
//        return self.playerNum
//    }
    
    func makePlay(cards: [Card]) {
        for selected_card in cards {
            for i in 0..<self.cards.count {
                if self.cards[i].getIdentifier() == selected_card.getIdentifier() {
                    self.cards.remove(at: i)
                    break
                }
            }
        }
    }
}

//public class Player2: Hashable, Codable {
//    public let id: String
//    
//    public init() {
//        self.id = NSUUID().uuidString
//    }
//    
//    public init(json: [String: Any]) throws {
//        guard let id = json["id"] as? String else {
//            throw PlayerError.creationFailed
//        }
//        
//        self.id = id
//    }
//    
//    public var hashValue: Int {
//        return self.id.hashValue
//    }
//    
//    public static func == (lhs: Player2, rhs: Player2) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
