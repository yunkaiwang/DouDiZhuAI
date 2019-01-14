//
//  DouDiZhuGame.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class DouDiZhuGame {
    private var deck: Deck = Deck()
    private var playerCardArr: [[Card]] = [[]]
    
    init() {
    }
    
    func newGame() {
        let newCards = deck.newGame()
        splitCards(cards: newCards)
    }
    
    func splitCards(cards: [Card]) {
        var cardOwner = Array(repeating: 0, count: 17)
        cardOwner.append(contentsOf: Array(repeating: 1, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 2, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 3, count: 3))
        
        cardOwner.shuffle()
        playerCardArr = Array(repeating: [], count: 4)
        
        for i in 0..<cardOwner.count {
            playerCardArr[cardOwner[i]].append(cards[i])
        }
        
        for i in 0..<playerCardArr.count {
            playerCardArr[i].sort()
            for card in playerCardArr[i] {
                print(card.getIdentifier())
            }
            print("\n")
        }
    }
}
