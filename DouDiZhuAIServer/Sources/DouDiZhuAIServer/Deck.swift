//
//  Deck.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class Deck {
    static let shared = Deck()
    private var deck = [Card]()
    private var playerCards = [[Card]]()
    
    // public
    
    public func newGame() {
        deck.shuffle()
        self.splitCard()
    }
    
    public func getPlayerCard(playerNum: PlayerNum) -> [Card] {
        switch playerNum {
        case .none:
            return []
        case .one:
            return self.playerCards[0]
        case .two:
            return self.playerCards[1]
        default:
            return self.playerCards[2]
        }
    }
    
    public func getLandlordCard() -> [Card] {
        return self.playerCards[3]
    }
    
    // private
    
    private init() {
        initializeDeckOfCards()
    }

    private func initializeDeckOfCards() {
        let suits = [Suit(type: SuitType.clubs), Suit(type: SuitType.diamonds), Suit(type: SuitType.hearts), Suit(type: SuitType.spades)]
        
        for suit in suits {
            for num in 1...13 {
                deck.append(NumCard(suit: suit, num: num))
            }
        }
        
        deck.append(JokerCard(type: JokerType.black))
        deck.append(JokerCard(type: JokerType.red))
    }
    
    private func splitCard() {
        var cardOwner = Array(repeating: 0, count: 17)
        cardOwner.append(contentsOf: Array(repeating: 1, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 2, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 3, count: 3))
        
        cardOwner.shuffle()
        self.playerCards = Array(repeating: [], count: 4)
        
        for i in 0..<cardOwner.count {
            self.playerCards[cardOwner[i]].append(deck[i])
        }
        
        for i in 0..<4 {
            self.playerCards[i].sort()
        }
    }
}
