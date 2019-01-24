//
//  ComputerPlayer.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-18.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class ComputerPlayer: Player {
    func chooseToBeLandlord() {
        self.beLandlord = Int.random(in: 0...1) == 1
    }
    
    func chooseToPillageLandlord() {
        self.pillageLandlord = Int.random(in: 0...1) == 1
    }
}
