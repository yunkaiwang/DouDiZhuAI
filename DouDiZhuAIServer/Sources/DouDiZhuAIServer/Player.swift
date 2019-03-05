//
//  Player.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

public enum PlayerError: Error {
    case creationFailed
}

public class Player: Hashable, Codable {
    public let id: String
    private var cards: [Card] = []
    private var beLandlord: Bool = false
    
    public init() {
        self.id = NSUUID().uuidString
    }
    
    public init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw PlayerError.creationFailed
        }
        
        self.id = id
    }
    
    func getNumCard()->Int {
        return self.cards.count
    }
    
    func getCards()->[Card] {
        return self.cards
    }
    
    func startNewGame(cards: [Card]) {
        self.cards = cards
    }
    
    func addLandlordCard(newCards: [Card]) {
        self.cards += newCards
        self.cards.sort()
    }
    
    public func pass() { }
    
    public func decideToBeLandlord(decision: Bool) {
        self.beLandlord = decision
    }
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}

