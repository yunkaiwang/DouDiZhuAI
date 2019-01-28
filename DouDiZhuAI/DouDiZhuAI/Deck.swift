//
//  Deck.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class Deck {
    private var deck = [Card]()
    
    init() {
        initializeDeckOfCards()
    }
    
    func initializeDeckOfCards() {
        let suits = [Suit(type: SuitType.clubs), Suit(type: SuitType.diamonds), Suit(type: SuitType.hearts), Suit(type: SuitType.spades)]
        
        for suit in suits {
            for num in 1...13 {
                deck.append(NumCard(suit: suit, num: num))
            }
        }
        
        deck.append(JokerCard(type: JokerType.black))
        deck.append(JokerCard(type: JokerType.red))
    }
    
    func newGame()->[Card] {
        deck.shuffle()
        return deck
    }
}
