//
//  ComputerPlayer.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

class ComputerPlayer: Player {
    func makeBeLandlordDecision() {
        let decision = Int.random(in:0...1) == 1
        self.decideToBeLandlord(decision: decision)
    }
    
    func makePillageLandlordDecision() {
        let decision = Int.random(in:0...1) == 1
        self.decideToBeLandlord(decision: decision)
    }
}
