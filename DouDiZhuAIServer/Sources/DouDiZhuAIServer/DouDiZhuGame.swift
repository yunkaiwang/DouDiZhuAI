//
//  Game.swift
//
//  Created by yunkai wang on 2019-03-04.
//
import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib
import Foundation

enum GameError: Error {
    case failedToSerializeMessageToJsonString(message: Message)
}

class DouDiZhuGame {
    static let shared = DouDiZhuGame()
    
    private var timer: Timer? = nil
    private var deck: Deck = Deck.shared
    private var playerSocketInfo: [Player: WebSocket?] = [:]
    private var playerAddedAIPlayers: [Player: [Player]] = [:]
    private var activePlayer: Player?
    private var landlord: Player?
    private var currentPlayerNum:Int
    private var currentPlay: Play
    
    private var pillagingLandlord: Bool
    private var beLandlordDecision:[Bool]
    private var pillageLandlordDecision:[Bool]
    
    private var players: [Player] {
        return Array(self.playerSocketInfo.keys)
    }
    
    private init() { // singleton
        self.landlord = nil
        self.pillagingLandlord = false
        self.beLandlordDecision = [false, false, false]
        self.pillageLandlordDecision = [false, false, false]
        self.currentPlayerNum = -1
        self.currentPlay = Play.none
    }
    
    func playerForSocket(_ aSocket: WebSocket) -> Player? {
        var aPlayer: Player? = nil
        
        self.playerSocketInfo.forEach { (player, socket) in
            if aSocket == socket {
                aPlayer = player
            }
        }
        
        return aPlayer
    }
    
    func handlePlayerLeft(player: Player) throws {
        if self.playerSocketInfo[player] != nil {
            self.playerSocketInfo.removeValue(forKey: player)
            for AIPlayer in playerAddedAIPlayers[player]! {
                self.playerSocketInfo.removeValue(forKey: AIPlayer)
            }
            
//            let message = Message.gameEnd(player: player)
//            try notifyPlayers(message: message)
        }
    }
    
    public func handleNewUserJoin(socket: WebSocket) throws {
        let player = Player()
        
        if try self.handleJoin(player: player, socket: socket) {
            var playerIDs: [String] = []
            for p in self.players {
                if p.id != player.id {
                    playerIDs.append(p.id)
                }
            }
            
            playerAddedAIPlayers[player] = []
            try notifyPlayer(message: Message.joinGameSucceeded(player: player, players: playerIDs), socket: socket)
            try notifyPlayers(message: Message.newUserJoined(player: player))
        } else {
            try notifyPlayer(message: Message.joinGameFailed(), socket: socket)
        }
    }
    
    public func handleAddAIPlayer(socket: WebSocket) throws {
        let AIPlayer = Player()
        if try self.handleJoin(player: AIPlayer, socket: nil) {
            let player = playerForSocket(socket)
            if player == nil {
                print("Cannot find the player, this should never happen")
                return
            }
            
            playerAddedAIPlayers[player!]!.append(AIPlayer)
            try notifyPlayers(message: Message.newUserJoined(player: AIPlayer))
        } else {
            try notifyPlayer(message: Message.addAIPlayerFailed(), socket: socket)
        }
    }
    
    public func handleStartGame(socket: WebSocket) throws {
        if self.playerSocketInfo.count < 3 {
            try notifyPlayer(message: Message.startGameFailed(), socket: socket)
        }
        self.newGame()
    }
    
    private func newGame() {
        deck.newGame()
        self.landlord = nil
        self.pillagingLandlord = false
        self.beLandlordDecision = [false, false, false]
        self.pillageLandlordDecision = [false, false, false]
        self.currentPlayerNum = -1
        self.currentPlay = Play.none
        
        for i in 0..<self.players.count {
            self.players[i].startNewGame(cards: deck.getPlayerCard(playerNum: i))
        }
    }
    
    private func isGameOver()->Bool {
        for i in 0..<self.players.count {
            if self.players[i].getNumCard() == 0 {
                return true
            }
        }
        return false
    }
    
    private func getWinner()->String? {
        if !isGameOver() || landlord == nil {
            return nil
        } else {
            if landlord!.getNumCard() == 0 {
                return "Landlord"
            } else {
                return "Farmer"
            }
        }
    }
    
    private func setLandlordAndStartGame(landlordNum: PlayerNum) {
        var landlord: Player, currentPlayerNum: Int
        switch landlordNum {
        case .one:
            landlord = self.players[0]
            currentPlayerNum = 0
        case .two:
            landlord = self.players[1]
            currentPlayerNum = 1
        default:
            landlord = self.players[2]
            currentPlayerNum = 2
        }
        self.landlord = landlord
        self.landlord?.addLandlordCard(newCards: deck.getLandlordCard())
        
        self.currentPlayerNum = currentPlayerNum
        self.runGame()
    }
    
    private func runGame() {
        
    }
    
    private func chooseLandlord() {
//        self.currentPlayerNum = Int.random(in: 0...2)
//
//
//        if currentPlayerNum == 0 {
//            letPlayerDecideLandlord(playerNum: 0)
//        } else if currentPlayerNum == 1 {
//            letPlayerDecideLandlord(playerNum: 1)
//            self.beLandlordDecision[1] = true
//            let decision = player2.wantToBeLandlord()
//            if decision {
//                self.pillagingLandlord = true
//                self.pillageLandlordDecision[2] = true
//            } else {
//                self.beLandlordDecision[2] = true
//            }
//            letPlayerDecideLandlord(playerNum: 2)
//            if !decision && player3.wantToBeLandlord() {
//                self.pillagingLandlord = true
//            }
//            letPlayerDecideLandlord(playerNum: 0)
//        } else {
//            letPlayerDecideLandlord(playerNum: 2)
//            self.beLandlordDecision[2] = true
//            if player3.wantToBeLandlord() {
//                self.pillagingLandlord = true
//            }
//            letPlayerDecideLandlord(playerNum: 0)
//        }
    }
    
    private func letPlayerDecideLandlord(playerNum: Int) {
//        if playerNum == 0 {
//
//            self.waitForPlayerChoise()
//        } else if playerNum == 1 {
//            var decision: Bool
//            var text: String
//            if self.pillagingLandlord {
//                player2.chooseToPillageLandlord()
//                decision = player2.wantToPillageLandlord()
//                text = "Pillage landlord"
//            } else {
//                player2.chooseToBeLandlord()
//                decision = player2.wantToBeLandlord()
//                text = "Be landlord"
//            }
//
//
//        } else {
//            var decision: Bool
//            var text: String
//            if self.pillagingLandlord {
//                player3.chooseToPillageLandlord()
//                decision = player3.wantToPillageLandlord()
//                text = "Pillage landlord"
//            } else {
//                player3.chooseToBeLandlord()
//                decision = player3.wantToBeLandlord()
//                text = "Be landlord"
//            }
//
//
//        }
    }
    
    private func playerChooseToBeLandlord() {
        
//        if !self.pillagingLandlord {
//            player1.decideToBeLandlord(decision: true)
//            self.pillagingLandlord = true
//            self.beLandlordDecision[0] = true
//            if self.beLandlordDecision[1] && self.beLandlordDecision[2] {
//                // since it's not pillaging landlord, so any of the two previous player must decide to not be the landlord as if they have decided, so current player can be safely picked as landlord
//                self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//            } else {
//                if self.beLandlordDecision[2] { // player 3 has decided but it's not in the pillaging process so player 3 must have decided to not be the landlord
//                    self.letPlayerDecideLandlord(playerNum: 1)
//                    let decision = player2.wantToPillageLandlord()
//                    if !decision {
//                        self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//                    } else {
//                        self.letPlayerDecideLandlord(playerNum: 1) // if player 2 wants to pillage landlord, then player 1 has to choose if he wants to pillage again
//                    }
//                } else { // player 3 has not decided as well, so only player 1 has made the choice
//                    self.letPlayerDecideLandlord(playerNum: 1)
//                    self.letPlayerDecideLandlord(playerNum: 2)
//
//                    let player2_decision = player2.wantToPillageLandlord()
//                    let player3_decision = player3.wantToPillageLandlord()
//                    if !player2_decision && !player3_decision { // both two players don't want to pillage the landlord
//                        self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//                    } else { // at least one of the player wants to pillage the landlord, so we need to let player 1 decide again if he wants to pillage the landlord
//                        self.letPlayerDecideLandlord(playerNum: 0)
//                    }
//                }
//            }
//        } else {
//            player1.decideToPillageLandlord(decision: true)
//            self.pillageLandlordDecision[0] = true
//
//            if self.pillageLandlordDecision[1] && self.pillageLandlordDecision[2] {
//                self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//            } else if !self.pillageLandlordDecision[1] && self.pillageLandlordDecision[2] { // player 2 had not decided to pillage or not, player 3 did, if we are in this case, then player 2 must be the player who first wants to be the landlord
//                letPlayerDecideLandlord(playerNum: 1)
//                let decision = player2.wantToPillageLandlord()
//
//                if decision {
//                    self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                } else if player3.wantToPillageLandlord() {
//                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                } else {
//                    self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//                }
//            } else { // if we are here, then it means that both player2 and player 3 must have not decided yet, and the only possibility when we are in this case is that player 3 is the first one who decided to be the landlord
//                letPlayerDecideLandlord(playerNum: 1)
//                letPlayerDecideLandlord(playerNum: 2)
//                let decision = player3.wantToPillageLandlord()
//
//                if decision {
//                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                } else {
//                    self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
//                }
//            }
//        }
    }
    
    private func playerChooseToBeFarmer() {
        
        
//        if !self.pillagingLandlord {
//            player1.decideToBeLandlord(decision: false)
//            self.beLandlordDecision[0] = true
//            if self.beLandlordDecision[1] && self.beLandlordDecision[2] {
//                // since it's not pillaging landlord, so any of the two previous player must decide to not be the landlord as if they have decided, so new game has to be started
//                
//                
//            } else {
//                if self.beLandlordDecision[2] {
//                    self.letPlayerDecideLandlord(playerNum: 1)
//                    let decision = player2.wantToBeLandlord()
//                    if !decision {
//                        
//                        
//                    } else {
//                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                    }
//                } else { // player 3 has not decided as well, so only player 1 has made the choice
//                    self.letPlayerDecideLandlord(playerNum: 1)
//                    let player2_decision = player2.wantToBeLandlord()
//                    var player3_decision: Bool
//                    if player2_decision {
//                        self.pillagingLandlord = true
//                        self.beLandlordDecision[1] = true
//                        player3.chooseToPillageLandlord()
//                        player3_decision = player3.wantToPillageLandlord()
//                        if !player3_decision {
//                            self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                        } else {
//                            player2.chooseToPillageLandlord()
//                            let player2_decision = player2.wantToPillageLandlord()
//                            if player2_decision {
//                                self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                            } else {
//                                self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                            }
//                        }
//                    } else {
//                        player3.chooseToBeLandlord()
//                        player3_decision = player3.wantToBeLandlord()
//                        if !player3_decision {
//                            
//                            
//                        } else {
//                            self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                        }
//                    }
//                }
//            }
//        } else {
//            player1.decideToPillageLandlord(decision: false)
//            self.pillageLandlordDecision[0] = true
//            
//            if self.pillageLandlordDecision[2] && !self.pillageLandlordDecision[1] {
//                let player3_decision = player3.wantToPillageLandlord()
//                if !player3_decision {
//                    self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                } else {
//                    letPlayerDecideLandlord(playerNum: 1)
//                    let player2_decision = player2.wantToPillageLandlord()
//                    if player2_decision {
//                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                    } else {
//                        self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                    }
//                }
//            } else {
//                letPlayerDecideLandlord(playerNum: 1)
//                let player2_decision = player2.wantToPillageLandlord()
//                if !player2_decision {
//                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                } else {
//                    letPlayerDecideLandlord(playerNum: 2)
//                    let player3_decision = player3.wantToPillageLandlord()
//                    if player3_decision {
//                        self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
//                    } else {
//                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
//                    }
//                }
//            }
//        }
    }
    
    private func didPlayerWin() -> Bool {
        return false
    }
    
    private func startGame() throws {
        self.activePlayer = randomPlayer()
        self.chooseLandlord()
        
        let message = Message.playerTurn(player: self.activePlayer!)
        try notifyPlayers(message: message)
    }
    
    private func randomPlayer() -> Player {
        let randomIdx = Int(arc4random() % UInt32(self.players.count))
        return players[randomIdx]
    }
    
    private func nextActivePlayer() -> Player? {
        return self.players.filter({ $0 != self.activePlayer }).first
    }
    
    private func notifyPlayer(message: Message, socket: WebSocket) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        socket.sendStringMessage(string: jsonString, final: true, completion: {
            print("did send message: \(message.type)")
        })
    }
    
    private func notifyPlayers(message: Message) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        self.playerSocketInfo.values.forEach({
            $0?.sendStringMessage(string: jsonString, final: true, completion: {
                print("did send message: \(message.type)")
            })
        })
    }
    
    private func handleJoin(player: Player, socket: WebSocket?) throws -> Bool {
        if self.playerSocketInfo.count > 3 {
            return false
        }
        
        self.playerSocketInfo[player] = socket
        return true
    }
}

