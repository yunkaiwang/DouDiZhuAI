//
//  DouDiZhuClientDelegate.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-03.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation
import Starscream

protocol DouDiZhuClientDelegate: class {
    func clientDidConnect()
    func clientDidDisconnect(error: Error?)
    func clientDidReceiveMessage(_ message: Message)
}

class DouDiZhuClient: WebSocketDelegate {
    weak var delegate: DouDiZhuClientDelegate?
    private var socket: WebSocket!
    
    init() {
        let url = URL(string: "http://localhost:8181/game")!
        let request = URLRequest(url: url)
        self.socket = WebSocket(request: request, protocols: ["DouDiZhu"], stream: FoundationStream())
        self.socket.delegate = self
    }
    
    // MARK: - Public
    
    func connect() {
        self.socket.connect()
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    func joinGame() {
        self.writeMessageToSocket(Message.joinGame())
    }
    
    func addAIPlayer() {
        self.writeMessageToSocket(Message.addAIPlayer())
    }
    
    func startGame() {
        self.writeMessageToSocket(Message.startGame())
    }
    
    func informDecision(beLandlord: Bool, playerID: String) {
        self.writeMessageToSocket(Message.informDecision(beLandlord: beLandlord, playerID: playerID))
    }
    
    func makePlay(cards: [Card], playerID: String) {
        self.writeMessageToSocket(Message.makePlay(playerID: playerID, cards: cards))
    }
    
    // MARK: - Private
    
    private func writeMessageToSocket(_ message: Message) {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(message)
            self.socket.write(data: jsonData)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.clientDidConnect()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.clientDidDisconnect(error: error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            print("failed to convert text into data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let message = try decoder.decode(Message.self, from: data)
            self.delegate?.clientDidReceiveMessage(message)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}
