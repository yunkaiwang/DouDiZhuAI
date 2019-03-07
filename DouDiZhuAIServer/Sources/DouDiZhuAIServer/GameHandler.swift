//
//  GameHandler.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib
import Foundation

class GameHandler: WebSocketSessionHandler {
    let socketProtocol: String? = "DouDiZhu"
    
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        socket.readStringMessage { (string, op, fin) in
            
            guard let string = string else {
                if let player = DouDiZhuGame.shared.playerForSocket(socket) {
                    print("socket closed for \(player.id)")
                    
                    do {
                        try DouDiZhuGame.shared.handlePlayerLeft(player)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                
                return socket.close()
            }
            
            do {
                let decoder = JSONDecoder()
                guard let data = string.data(using: .utf8) else {
                    return print("failed to covert string into data object: \(string)")
                }
                
                let message: Message = try decoder.decode(Message.self, from: data)
                switch message.type {
                case .joinGame:
                    try DouDiZhuGame.shared.handleNewUserJoin(socket)
                case .addAIPlayer:
                    try DouDiZhuGame.shared.handleAddAIPlayer(socket)
                case .startGame:
                    try DouDiZhuGame.shared.handleStartGame(socket)
                case .playerWantToBeFarmer, .playerWantToBeLandlord:
                    guard let playerID = message.playerID else {
                        print("No player ID is provided within the message, this should never happen")
                        return
                    }

                    try DouDiZhuGame.shared.playerMadeDecision(playerID: playerID, decision: (message.type == .playerWantToBeLandlord ? true : false))
                    
                case .makePlay:
                    
                    break
                default:
                    break
                }
            } catch {
                print("Failed to decode JSON from Received Socket Message")
            }
            
            // Done working on this message? Loop back around and read the next message.
            self.handleSession(request: request, socket: socket)
        }
    }
}
