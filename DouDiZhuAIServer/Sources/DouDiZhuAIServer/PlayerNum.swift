//
//  PlayerNum.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

public enum PlayerNum: Int {
    case none = 0
    case one = 1
    case two
    case three
    
    func getNext() -> PlayerNum {
        switch self {
        case .none:
            return .none
        case .one:
            return .two
        case .two:
            return .three
        default:
            return .one
        }
    }
}
