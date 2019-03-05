//
//  Game.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-04.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import SpriteKit

enum GameError: Error {
    case noPlayerIDProvided
}

class Game {
    static let sharedInstace = Game()
    static var gameScene: GameScene? = nil
    
    private (set) var client = DouDiZhuClient()
    private (set) var state: GameState = .disconnected
    private (set) var player: Player?
    
    public func start() {
        self.client.delegate = self
        self.client.connect()
    }
    
    public func stop() {
        self.client.disconnect()
    }
    
    public func isConnected() -> Bool {
        return self.state == GameState.connected
    }
    
    private func joinGame() {
        self.client.joinGame()
    }
    
    private init() { /* singleton */ }
}

extension Game: DouDiZhuClientDelegate {
    func clientDidDisconnect(error: Error?) {
        self.state = .disconnected
        if error != nil {
            Game.gameScene?.showAlert(withTitle: "Connection failed", message: "Failed to connect to the server, please try again!")
        }
    }
    
    func clientDidConnect() {
        self.state = .connected
        self.joinGame()
    }
    
    func clientDidReceiveMessage(_ message: Message) {
        switch message.type {
        case .joinGameSucceded:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            print("received join game succede message and id is", playerID)
            self.player = Player(id: playerID)
            Game.gameScene?.enterGameScene()
            return
        case .joinGameFailed:
            Game.gameScene?.showAlert(withTitle: "Join failed", message: "Failed to join the game, please try again")
            return
        case .gameEnd:
            if let winningPlayer = message.playerID {
                self.state = (winningPlayer == self.player?.id) ? .playerWon : .playerLost
            } else {
                self.state = .draw
            }
            return
        case .playerTurn:
            guard let activePlayer = message.playerID else {
                print("no player found - this should never happen")
                return
            }
            
            if activePlayer == self.player?.id {
                self.state = .active
            } else {
                self.state = .waiting
            }
            return
        default: break
        }
    }
}
