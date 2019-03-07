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

public class Player {
    public let id: String
    private var cards: [Card]
    private var playerNum: PlayerNum
    
    init(id: String, num: PlayerNum) {
        self.id = id
        self.cards = []
        self.playerNum = num
    }
    
    func getNumCard()->Int {
        return self.cards.count
    }
    
    func getCards()->[Card] {
        return self.cards
    }
    
    func getPlayerNum()->PlayerNum{
        return self.playerNum
    }
    
    func startNewGame(cards: [Card]) {
        self.cards = cards
    }
    
    func addLandlordCard(newCards: [Card]) {
        self.cards += newCards
        self.cards.sort()
    }
    
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
