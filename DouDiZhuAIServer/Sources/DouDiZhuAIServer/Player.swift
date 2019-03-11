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
    private var state: DecisionState = .undecided
    
    public init(_ socket: WebSocket?) {
        self.id = NSUUID().uuidString
        self.socket = socket
    }
    
    public func startNewGame(cards: [Card]) {
        self.state = .undecided
        self.cards = cards
    }
    
    public func addLandlordCard(newCards: [Card]) {
        self.cards += newCards
        self.cards.sort()
    }
    
    public func getCards()->[Card] {
        return self.cards
    }
    
    public func getPlayerNum() -> PlayerNum {
        return self.playerNum
    }
    
    public func setPlayerNum(playerNum: PlayerNum) {
        self.playerNum = playerNum
    }
    
    public func getSocket() -> WebSocket? {
        return self.socket
    }
    
    public func getNumCard()->Int {
        return self.cards.count
    }
    
    public func makeDecision(decision: Bool) {
        switch self.state {
        case .undecided:
            self.state = decision ? .beLandlord : .beFarmer
        default:
            self.state = decision ? .pillage : .noPillage
        }
    }
    
    public func hasMadeDecision() -> Bool {
        return self.state != .undecided
    }
    
    public func hasMadePillageDecision() -> Bool {
        return self.state == .noPillage || self.state == .pillage
    }
    
    public func wantToBeLandlord() -> Bool {
        return self.state == .beLandlord || self.state == .pillage
    }
    
    public func pass() { }
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func makePlay(cards: [Card]) throws {
        for selected_card in cards {
            var found: Bool = false
            for i in 0..<self.cards.count {
                if self.cards[i].getIdentifier() == selected_card.getIdentifier() {
                    self.cards.remove(at: i)
                    found = true
                    break
                }
            }
            
            if !found {
                throw GameError.cardNotFoundError
            }
        }
    }
}

