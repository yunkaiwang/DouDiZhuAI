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
    
    func makeBeLandlordDecision() {
    }
    
    func makePillageLandlordDecision() {
    }
}
