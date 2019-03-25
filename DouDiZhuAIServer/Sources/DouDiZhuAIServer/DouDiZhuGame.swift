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
    case cardNotFoundError
    case invalidPlay
    case playerLeftWhileGameInProgress
    case unknowError
}

class DouDiZhuGame {
    static let shared = DouDiZhuGame()
    
    private var deck: Deck = Deck.shared
    private var playerAddedAIPlayers: [Player: [Player]] = [:]
    private var activePlayer: Player? = nil
    private var landlord: Player? = nil
    private var currentPlay: Play? = nil
    private var lastPlayedPlayer: Player? = nil
    private var firstPlayerCalledLandlord: String = ""
    private (set) var state: GameState = .created
    private var players: [Player] = []
    
    private var availablePlayerNums: [PlayerNum] {
        var playerNums: [PlayerNum] = []
        var player1Used: Bool = false, player2Used: Bool = false, player3Used: Bool = false
        for player in self.players {
            if player.getPlayerNum() == .one {
                player1Used = true
            } else if player.getPlayerNum() == .two {
                player2Used = true
            } else if player.getPlayerNum() == .two {
                player2Used = true
            }
        }
        if !player1Used {
            playerNums.append(PlayerNum.one)
        }
        if !player2Used {
            playerNums.append(PlayerNum.two)
        }
        if !player3Used {
            playerNums.append(PlayerNum.three)
        }
        return playerNums
    }
    
    public func playerForSocket(_ aSocket: WebSocket) -> Player? {
        var aPlayer: Player? = nil
        
        self.players.forEach { player in
            if aSocket == player.getSocket() {
                aPlayer = player
            }
        }
        
        return aPlayer
    }
    
    public func handlePlayerLeft(_ player: Player) throws {
        if self.state != .created {
            throw GameError.playerLeftWhileGameInProgress
        } else {
            self.removePlayer(player)
            try notifyPlayers(Message.userLeft(player: player))
            if !(player is AIPlayer) {
                for AIPlayer in playerAddedAIPlayers[player]! {
                    self.removePlayer(AIPlayer)
                    try notifyPlayers(Message.userLeft(player: AIPlayer))
                }
            }
            self.playerAddedAIPlayers.removeValue(forKey: player)
        }
    }
    
    public func handleNewUserJoin(_ socket: WebSocket) throws {
        let player = Player(socket)
        
        if try self.handleJoin(player) {
            var playerIDs: [String] = []
            for p in self.players {
                if p.id != player.id {
                    playerIDs.append(p.id)
                }
            }
            
            playerAddedAIPlayers[player] = []
            try notifyPlayer(Message.joinGameSucceeded(player: player, players: playerIDs), socket: socket)
            try notifyPlayers(Message.newUserJoined(player: player))
        } else {
            try notifyPlayer(Message.joinGameFailed(), socket: socket)
        }
    }
    
    public func handleAddAIPlayer(_ socket: WebSocket) throws {
        guard let player = playerForSocket(socket) else { return }
        
        let aiPlayer = AIPlayer()
        if try self.handleJoin(aiPlayer) {
            var playerIDs: [String] = []
            for p in self.players {
                if p.id != aiPlayer.id {
                    playerIDs.append(p.id)
                }
            }
            
            aiPlayer.receiveMessage(Message.joinGameSucceeded(player: aiPlayer, players: playerIDs))
            playerAddedAIPlayers[player]!.append(aiPlayer)
            try notifyPlayers(Message.newUserJoined(player: aiPlayer))
        } else {
            try notifyPlayer(Message.addAIPlayerFailed(), socket: socket)
        }
    }
    
    public func handleRemoveAIPlayer(_ socket: WebSocket) throws {
        guard let player = playerForSocket(socket) else { return }
        if (playerAddedAIPlayers[player]?.count ?? 0) == 0 {
            return
        }
        let aiPlayer = playerAddedAIPlayers[player]![0]
        playerAddedAIPlayers[player]!.remove(at: 0)
        try self.handlePlayerLeft(aiPlayer)
    }
    
    public func handleStartGame(_ socket: WebSocket) throws {
        if self.state != .created || self.players.count < 3 {
            try notifyPlayer(Message.startGameFailed(), socket: socket)
            return
        }
        try self.newGame()
    }
    
    public func playerMadeDecision(playerID: String, decision: Bool) throws {
        try notifyPlayers(Message.informDecision(beLandlord: decision, playerID: playerID))
        guard let player: Player = findPlayerWithID(playerID) else { throw GameError.unknowError }
        player.makeDecision(decision: decision)
        self.activePlayer = findPlayerWithNum(player.getPlayerNum().getNext())
        guard self.activePlayer != nil else { throw GameError.unknowError }
        
        if self.state == .choosingLandlord {
            if decision {
                self.firstPlayerCalledLandlord = playerID
                self.state = .pillagingLandlord
                if !(self.activePlayer!.hasMadeDecision()) { // next player has not make any decision, so they can choose to pillage the landlord or not
                    try notifyPlayers(Message.playerPillageTurn(player: self.activePlayer))
                } else { // next player has made decision, so current player is the only one who choose to be the landlord, so current player will be the landlord, and no pillage stage is needed
                    try self.decideLandlord(player)
                }
            } else {
                // player decides to not be the landlord, and next player has decided as well, so no one chosed to be the landlord, restart the game
                if (self.activePlayer?.hasMadeDecision() ?? true) {
                    try self.startNewGameSinceNoOneChooseToBeLandlord()
                } else {
                    // next player has not decided, so let he decide
                    try notifyPlayers(Message.playerDecisionTurn(player: self.activePlayer))
                }
            }
        } else {
            if decision {
                // player wanted to be the landlord, and now he made the same decision again, so he will be elected as the landlord
                if firstPlayerCalledLandlord == playerID {
                    try self.decideLandlord(player)
                } else {
                    // current player is not the first player who called the landlord, the next player may or may not have decided, only if the next player has decided not to be the landlord, then we will let the next next player decide
                    if !(self.activePlayer!.hasMadeDecision()) || self.activePlayer!.wantToBeLandlord() {
                        try notifyPlayers(Message.playerPillageTurn(player: self.activePlayer))
                    } else {
                        // current player is not the first player who called the landlord, and next player has decided to not be the landlord, so the next next player must be the one who called the landlord
                        self.activePlayer = findPlayerWithNum(self.activePlayer!.getPlayerNum().getNext())
                        guard self.activePlayer != nil else { throw GameError.unknowError }
                        
                        try notifyPlayers(Message.playerPillageTurn(player: self.activePlayer))
                    }
                }
            } else { // player choose to not be the landlord, and it's currently pillaging landlord
                // one round of pillage has finished
                if firstPlayerCalledLandlord == playerID {
                    // if next player wanted to be the landlord, let him become the landlord
                    if self.activePlayer!.wantToBeLandlord() {
                        try decideLandlord(self.activePlayer!)
                    } else {
                        // if next player doesn't want to be the landlord, and the current player still has to make the decision, then it means that the next next player wants to be the landlord, so let him be it
                        self.activePlayer = findPlayerWithNum(self.activePlayer!.getPlayerNum().getNext())
                        guard self.activePlayer != nil else { throw GameError.unknowError }
                        try decideLandlord(self.activePlayer!)
                    }
                } else {
                    guard let previousPlayer = findPlayerWithNum(self.activePlayer!.getPlayerNum().getNext()) else { throw GameError.unknowError }
                    // current player's next player is the one who first called the landlord, so we need to check a couple of things here
                    // 1. if no one other than the original player wants to be the landlord, automatically assign the landlord position to him
                    // 2. the other player wanted to be the landlord, so we need another round for the original player who first called the landlord to decide whether he still wants to be the landlord or not
                    if self.activePlayer!.id == firstPlayerCalledLandlord {
                        if previousPlayer.wantToBeLandlord() {
                            try notifyPlayers(Message.playerPillageTurn(player: self.activePlayer))
                        } else {
                            try decideLandlord(self.activePlayer!)
                        }
                    } else {
                        // next player is not the one who called the landlord
                        if self.activePlayer!.hasMadeDecision() && !self.activePlayer!.wantToBeLandlord() {
                            try decideLandlord(previousPlayer)
                        } else {
                            try notifyPlayers(Message.playerPillageTurn(player: self.activePlayer))
                        }
                    }
                }
            }
        }
    }
    
    public func playerMakePlay(_ id: String, cards: [Card]) throws {
        if id != self.activePlayer?.id {
            return
        }
    
        let play: Play = try Play(cards)
        if !isCurrentPlayValid(play: play) {
            print("aborting since invalid play")
            throw GameError.invalidPlay
        }
        let player: Player = findPlayerWithID(id)!
        
        if cards.count != 0 {
            self.currentPlay = play
            self.lastPlayedPlayer = player
            try player.makePlay(cards: cards)
        }
        
        try self.notifyPlayers(Message.informPlay(player: player, cards: cards))
        self.activePlayer = self.findPlayerWithNum(player.getPlayerNum().getNext())
        try self.runGame()
    }
    
    // May add more code to handle different type of error later on (to do)
    public func handleError() {
        do {
            try self.abortGame()
        } catch {
            print("DouDiZhu game failed to handle the error, exiting...")
            exit(1)
        }
    }
    
    // TO DO
    // abort the game sine an unknow error has occured, or when no one chooses to be the landlord
    private func abortGame() throws {
        try self.notifyPlayers(Message.abortGame())
        self.clearGameStateForNewGame()
    }
    
    private func findPlayerWithID(_ id: String) -> Player? {
        for player in self.players {
            if player.id == id {
                return player
            }
        }
        return nil
    }
    
    private func findPlayerWithNum(_ num: PlayerNum) -> Player? {
        for player in self.players {
            if player.getPlayerNum() == num {
                return player
            }
        }
        return nil
    }
    
    private func newGame() throws {
        self.state = .started
        self.landlord = nil
        self.currentPlay = .none
        deck.newGame()

        for player in self.players {
            player.startNewGame(cards: deck.getPlayerCard(playerNum: player.getPlayerNum()))
            let message: Message = Message.startGame(player: player, cards: deck.getPlayerCard(playerNum: player.getPlayerNum()))
            if player is AIPlayer {
                (player as! AIPlayer).receiveMessage(message)
            } else {
                try self.notifyPlayer(message, socket: player.getSocket())
            }
        }
        
        try electLandlord()
    }
    
    private func isGameOver()->Bool {
        if self.state != .inProgress { // game can only end when the game is in progress
            return false
        }
        for i in 0..<self.players.count {
            if self.players[i].getNumCard() == 0 {
                return true
            }
        }
        return false
    }
    
    private func getWinner()->Player? {
        if self.state != .inProgress {
            return nil
        } else {
            for i in 0..<self.players.count {
                if self.players[i].getNumCard() == 0 {
                    return self.players[i]
                }
            }
            return nil
        }
    }
    
    private func runGame() throws {
        self.state = .inProgress
        if isGameOver() {
            try self.gameEnded()
        } else {
            try notifyPlayers(Message.playerTurn(player: self.activePlayer))
        }
    }
    
    private func gameEnded() throws {
        if !isGameOver() {
            return
        }
        let winner: Player? = self.getWinner()
        try notifyPlayers(Message.gameEnded(player: winner))
        
        self.clearGameStateForNewGame()
    }
    
    private func clearGameStateForNewGame() {
        self.playerAddedAIPlayers = [:]
        self.activePlayer = nil
        self.landlord = nil
        self.currentPlay = nil
        self.lastPlayedPlayer = nil
        self.state = .created
        self.players = []
        self.firstPlayerCalledLandlord = ""
    }
    
    private func electLandlord() throws {
        self.state = .choosingLandlord
        
        let rand = Int.random(in: 0...2)
        self.activePlayer = rand == 0 ? self.players[0] : (rand == 1 ? self.players[1] : self.players[2])
        
        try notifyPlayers(Message.playerDecisionTurn(player: self.activePlayer))
    }
    
    private init() { } // singleton
    
    private func decideLandlord(_ landlord: Player) throws {
        try self.notifyLandlord(landlord)
    }
    
    private func notifyPlayer(_ message: Message, socket: WebSocket?) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        socket?.sendStringMessage(string: jsonString, final: true, completion: {
            print("did send message: \(message.type)")
        })
    }
    
    private func notifyPlayers(_ message: Message) throws {
        try self.players.forEach({
            if $0 is AIPlayer {
                ($0 as! AIPlayer).receiveMessage(message)
            } else {
                try self.notifyPlayer(message, socket: $0.getSocket())
            }
        })
    }
    
    private func handleJoin(_ player: Player) throws -> Bool {
        if self.players.count >= 3 {
            return false
        }
        
        player.setPlayerNum(playerNum: self.availablePlayerNums[0])
        self.players.append(player)
        return true
    }
    
    private func removePlayer(_ player: Player) {
        for i in 0..<self.players.count {
            if self.players[i].id == player.id {
                self.players.remove(at: i)
                return
            }
        }
    }
    
    private func notifyLandlord(_ landlord: Player) throws {
        self.landlord = landlord
        self.activePlayer = landlord
        let landlordCards = Deck.shared.getLandlordCard()
        landlord.addLandlordCard(newCards: landlordCards)
        try notifyPlayers(Message.informLandlord(playerID: landlord.id, landlordCards: landlordCards))
        try self.runGame()
    }
    
    private func startNewGameSinceNoOneChooseToBeLandlord() throws {
        try self.newGame()
    }
    
    private func canPass()-> Bool {
        return self.activePlayer?.id != self.lastPlayedPlayer?.id && self.currentPlay?.playType() != .none
    }
    
    private func isCurrentPlayValid(play: Play) -> Bool {
        if canPass() && play.playType() == .none {
            return true
        }

        if self.activePlayer == self.lastPlayedPlayer || self.lastPlayedPlayer == nil {
            return play.playType() != .none
        }
        return (self.currentPlay ?? Play()) < play
    }
}

