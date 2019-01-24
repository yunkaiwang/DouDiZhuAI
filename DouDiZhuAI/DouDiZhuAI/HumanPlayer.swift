//
//  HumanPlayer.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-18.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

class HumanPlayer: Player {
    func decideToBeLandlord(decision:Bool) {
        self.beLandlord = decision
    }
    
    func decideToPillageLandlord(decision:Bool) {
        self.pillageLandlord = decision
    }
}
