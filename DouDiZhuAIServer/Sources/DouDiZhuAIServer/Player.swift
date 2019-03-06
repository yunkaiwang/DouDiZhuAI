//
//  Player.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import PerfectWebSockets
import Foundation

public class Player: Hashable {
    public let id: String
    private var cards: [Card] = []
    private var beLandlord: Bool = false
    private var playerNum: PlayerNum = .none
    private var socket: WebSocket? = nil
    
    public init(_ socket: WebSocket?) {
        self.id = NSUUID().uuidString
        self.socket = socket
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
    
    func getPlayerNum() -> PlayerNum {
        return self.playerNum
    }
    
    func setPlayerNum(playerNum: PlayerNum) {
        self.playerNum = playerNum
    }
    
    func getSocket() -> WebSocket? {
        return self.socket
    }
    
    public func getNumCard()->Int {
        return self.cards.count
    }
    
    public func pass() { }
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}

