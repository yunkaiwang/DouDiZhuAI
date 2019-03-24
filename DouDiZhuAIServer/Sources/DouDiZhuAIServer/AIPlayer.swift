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
//    private var lastPlayedCards: [Card] = []
    private var currentPlay: Play? = nil
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
        
        return suggestPlay(playerCards: self.getCards(), lastPlay: self.currentPlay ?? Play())
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
        if id != self.id {
            self.removeCardsFromRemainingCards(cards)
        }
        if cards.count != 0 {
            do {
                try self.currentPlay = Play(cards)
            } catch {
                exit(1)
            }
            self.lastPlayedPlayer = id
        }
    }
    
    private func playerTurn(_ id: String) {
        if id != self.id { // it's other players turn, so ignore
            return
        }
        
        var play: [Card] = []
        if self.id == lastPlayedPlayer || lastPlayedPlayer == "" || currentPlay?.playType() == .none {
            play = suggestNewPlay(playerCards: self.getCards())
        } else {
            play = suggestPlay(playerCards: self.getCards(), lastPlay: currentPlay ?? Play())
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
    
    public func calculateHeuristic() -> Int {
        let rank = calculateTotalCardRank(self.getCards())
        let numTurn = calculateNumTurnNeeded(self.getCards())
        
        return (20 - numTurn) * rank
    }
    
    private func calculateTotalCardRank(_ cards: [Card]) -> Int {
        var totalRank: Int = 0
        
        for card in cards {
            totalRank += card.getRank()
        }
        
        return totalRank
    }
    
    private func calculateNumTurnNeeded(_ cards: [Card]) -> Int {
        let parsed = parseCards(cards: cards)
        
        if cards.count == 0 {
            return 0
        } else if cards.count == 1 {
            return 1
        } else if cards.count == 2 {
            if parsed.jokerCards.count == 2 { // rocket play
                return 1
            } else if parsed.max_card_count == 2 { // pair play
                return 1
            }
            
            // two different cards, so need 2 turns to play
            return 2
        } else if cards.count == 3 {
            if parsed.max_card_count == 3 { // trio play
                return 1;
            } else if parsed.max_card_count == 2 || parsed.jokerCards.count == 2 { // has a pair or rocket
                return 2;
            }
            return 3
        } else if cards.count == 4 {
            if parsed.max_card_count == 4 || parsed.max_card_count == 3 { // bomb, trio + 1
                return 1
            } else if parsed.jokerCards.count == 2 { // has a rocket, still need to check how to play the rest of the cards, if a pair is left, then we need 2 turns, otherwise we need 3 turns
                return 1 + parsed.max_card_count == 2 ? 1 : 2
            } else if parsed.max_card_count == 1 { // has to make four solo plays
                return 4
            }
            
            var leftCards: [Card] = []
            for card in parsed.jokerCards {
                leftCards.append(card)
            }
            
            for card in parsed.numCards {
                if (parsed.card_count[card.getNum()] ?? 0) != 2 {
                    leftCards.append(card)
                }
            }
            
            // if no card is left, then it means we have two pairs, otherwise, we have a pair plus two other cards and they cannot be played together, so we need 3 turn
            return leftCards.count == 0 ? 2 : 3
        } else if cards.count == 5 {
            if parsed.max_card_count == 4 { // bomb and a solo card
                return 2
            } else if parsed.jokerCards.count == 2 { // has a rocket, think about how to play the rest
                return 1 + calculateNumTurnNeeded(parsed.numCards)
            } else if parsed.max_card_count == 3 {
                if parsed.jokerCards.count != 0 { // has a joker card, so need to play a 3+1 and a solo play
                    return 2
                } else {
                    var leftCards: [NumCard] = []
                    
                    for card in parsed.numCards {
                        if (parsed.card_count[card.getNum()] ?? 0) != 3 {
                            leftCards.append(card)
                        }
                    }
                    
                    if leftCards[0].getNum() == leftCards[1].getNum() { // left is a pair, make a 3+2 play
                        return 1
                    } else { // 2 solo cards are left, can make a 3+1 and solo play
                        return 2
                    }
                }
            } else if parsed.max_card_count == 2 {
                var leftCards: [NumCard] = []
                
                for card in parsed.numCards {
                    if (parsed.card_count[card.getNum()] ?? 0) != 2 {
                        leftCards.append(card)
                    }
                }
                if leftCards.count == 0 || leftCards.count == 1 { // we have 2 pairs
                    return 3
                } else {
                    return 4
                }
            } else {
                // no joker cards, no 2, and is a chain of length 5, so we need only 1 turn
                if parsed.max.getNum() - parsed.min.getNum() == 5 && parsed.max.getNum() != 2 && parsed.jokerCards.count == 0 {
                    return 1
                }
                
                // all other cases, we have 5 solo cards, so we need 5 turns
                return 5
            }
        }
        
        var contained: [Bool] = [Bool](repeating: false, count: cards.count)
        let maxPlay = suggestNewPlay(playerCards: cards)
        for card in maxPlay {
            for i in 0..<cards.count {
                if cards[i] == card {
                    contained[i] = true
                    break
                }
            }
        }
        
        var remainingCards: [Card] = []
        for i in 0..<cards.count {
            if !contained[i] {
                remainingCards.append(cards[i])
            }
        }
        
        return 1 + calculateNumTurnNeeded(remainingCards)
    }
}
