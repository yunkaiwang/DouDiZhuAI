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
                    } catch is GameError {
                        do {
                            try DouDiZhuGame.shared.handleError()
                        } catch {
                            print("Unknow error happened, server will exit...")
                            exit(1)
                        }
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
                    guard let playerID = message.playerID else {
                        print("No player ID is provided within the message, this should never happen")
                        return
                    }
                    
                    var convertedCards: [Card] = []
                    for card in message.cards {
                        convertedCards.append(Card.identifierToCard(id: card.getIdentifier()))
                    }
                    try DouDiZhuGame.shared.playerMakePlay(playerID, cards: convertedCards)
                default:
                    break
                }
            } catch is GameError {
                do {
                    try DouDiZhuGame.shared.handleError()
                } catch {
                    print("Unknow error happened, server will exit...")
                    exit(1)
                }
            } catch {
                print("Unknow error happened, server will exit...")
                exit(1)
            }
            
            // Done working on this message? Loop back around and read the next message.
            self.handleSession(request: request, socket: socket)
        }
    }
}
