//
//  Player.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-18.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class Player {
    private var cards: [Card]
    private var playerNum: PlayerNum
    internal var beLandlord: Bool
    internal var pillageLandlord: Bool
    
    init(num: PlayerNum) {
        self.cards = []
        self.playerNum = num
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
    
    func getPlayerNum()->PlayerNum {
        return self.playerNum
    }
}
