//
//  ComputerPlayer.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import PerfectWebSockets
import Foundation

class AIPlayer: Player {
    convenience init() {
        self.init(nil)
    }
    
    private override init(_ socket: WebSocket?) {
        super.init(socket)
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
    
    public func receiveMessage(_ message: Message) {
        print("AI player received a message", message.type)
    }
}
