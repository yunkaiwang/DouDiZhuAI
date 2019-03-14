//
//  ComputerPlayer.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import PerfectWebSockets
import Foundation

class AIPlayer: Player {
    private var player2: String = ""
    private var player3: String = ""
    private var landlordID: String = ""
    private var player2PlayedCards: [Card] = []
    private var player3PlayedCards: [Card] = []
    private var landlordCards: [Card] = []
    private var lastPlayedCards: [Card] = []
    private var lastPlayedPlayer: String = ""
    private var nextPlayer: String = ""
    private var cardsLeft: [Card] = [] // all cards that other players may have
    
    convenience init() {
        self.init(nil)
    }
    
    private override init(_ socket: WebSocket?) {
        super.init(socket)
        self.cardsLeft = Deck.initializeDeckOfCards()
    }
    
    public func makeBeLandlordDecision(_ pillage: Bool)-> Bool {
        return Int.random(in: 0...1) == 0
    }
    
    public func makePlay(lastPlayedPlayer: String, lastPlayedCard: [Card])->[Card] {
        if self.id == lastPlayedPlayer || lastPlayedPlayer == "" || lastPlayedCard.count == 0 {
            return suggestNewPlay(playerCards: self.getCards())
        }
        
        return suggestPlay(playerCards: self.getCards(), currentPlay: checkPlay(cards: lastPlayedCard), lastPlayedCards: lastPlayedCard)
    }
    
    public func receiveMessage(_ message: Message) throws {
        guard let playerID = message.playerID else {
            print("No player ID is provided within the message, this should never happen")
            throw GameError.unknowError
        }
        
        print("AI player received a message", message.type, self.getCards().count)
        
        switch message.type {
        case .joinGameSucceded:
            return
        case .newUserJoined:
            self.addNewPlayer(playerID)
            return
        case .gameStarted:
            // may be start a new thread and start computing whether or not the AI should be the landlord or not
            self.removeCardsFromRemainingCards(self.getCards())
        case .makePlay:
            playerMakePlay(playerID, cards: message.cards)
        case .informLandlord:
            self.landlordID = playerID
            self.landlordCards = message.cards
        case .abortGame:
            // do nothing when the game is aborted, if implement as a multi-thread program, we can stop the other threads here
            return
        case .playerTurn:
            playerTurn(playerID)
        case .playerDecisionTurn, .playerPillageTurn:
            playerDecisionTurn(playerID, message.type == .playerPillageTurn ? true: false)
        default:
            print("unknow message received by AI, this should not happen")
            return
        }
    }
    
    // check whether or not a specific card is still left on the table
    private func cardStillLeftOnTable(_ card: Card)->Bool {
        for left_card in self.cardsLeft {
            if left_card.getIdentifier() == card.getIdentifier() {
                return true
            }
        }
        return false
    }
    
    private func removeCardsFromRemainingCards(_ cards: [Card]) {
        for card in cards {
            for i in 0..<self.cardsLeft.count {
                if self.cardsLeft[i].getIdentifier() == card.getIdentifier() {
                    self.cardsLeft.remove(at: i)
                    break
                }
            }
        }
    }
    
    private func addNewPlayer(_ id: String) {
        if self.player2 == "" {
            self.player2 = id
        } else {
            self.player3 = id
        }
    }
    
    private func playerMakePlay(_ id: String, cards: [Card]) {
        self.removeCardsFromRemainingCards(cards)
        if cards.count != 0 {
            self.lastPlayedCards = cards
            self.lastPlayedPlayer = id
        }
    }
    
    private func playerTurn(_ id: String) {
        if id != self.id { // it's other players turn, so ignore
            return
        }
        
        var play: [Card] = []
        if self.id == lastPlayedPlayer || lastPlayedPlayer == "" || lastPlayedCards.count == 0 {
            play = suggestNewPlay(playerCards: self.getCards())
        } else {
            play = suggestPlay(playerCards: self.getCards(), currentPlay: checkPlay(cards: lastPlayedCards), lastPlayedCards: lastPlayedCards)
        }
        
        do {
            try DouDiZhuGame.shared.playerMakePlay(self.id, cards: play)
        } catch {
            print("AI player cannot make a play due to some unknown error...")
            DouDiZhuGame.shared.handleError()
        }
    }
    
    private func playerDecisionTurn(_ id: String, _ pillage: Bool) {
        if id != self.id { // it's other players turn, so ignore
            return
        }
        
        do {
            try DouDiZhuGame.shared.playerMadeDecision(playerID: self.id, decision: Int.random(in: 0...1) == 0)
        } catch {
            print("AI player cannot make the decision due to some unknown error...")
            DouDiZhuGame.shared.handleError()
        }
    }
}
