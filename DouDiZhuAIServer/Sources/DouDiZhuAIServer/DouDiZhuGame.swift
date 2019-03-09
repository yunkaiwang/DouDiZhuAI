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
    case unknowError
}

class DouDiZhuGame {
    static let shared = DouDiZhuGame()
    
    private var timer: Timer? = nil
    private var deck: Deck = Deck.shared
    private var playerAddedAIPlayers: [Player: [Player]] = [:]
    private var activePlayer: Player? = nil
    private var landlord: Player? = nil
    private var currentPlay: Play = .none
    private var lastPlayedPlayer: Player? = nil
    private var lastPlayedCard: [Card] = []
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
    
    
    private init() { } // singleton
    
    func playerForSocket(_ aSocket: WebSocket) -> Player? {
        var aPlayer: Player? = nil
        
        self.players.forEach { player in
            if aSocket == player.getSocket() {
                aPlayer = player
            }
        }
        
        return aPlayer
    }
    
    func handlePlayerLeft(_ player: Player) throws {
        self.removePlayer(player)
        for AIPlayer in playerAddedAIPlayers[player]! {
            self.removePlayer(AIPlayer)
        }
        self.playerAddedAIPlayers.removeValue(forKey: player)
        self.state = .created
//            let message = Message.gameEnd(player: player)
//            try notifyPlayers(message: message)
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
            try notifyPlayer(message: Message.joinGameSucceeded(player: player, players: playerIDs), socket: socket)
            try notifyPlayers(message: Message.newUserJoined(player: player))
        } else {
            try notifyPlayer(message: Message.joinGameFailed(), socket: socket)
        }
    }
    
    public func handleAddAIPlayer(_ socket: WebSocket) throws {
        let aiPlayer = AIPlayer()
        if try self.handleJoin(aiPlayer) {
            let player = playerForSocket(socket)
            if player == nil {
                print("Cannot find the player, this should never happen")
                return
            }
            
            playerAddedAIPlayers[player!]!.append(aiPlayer)
            try notifyPlayers(message: Message.newUserJoined(player: aiPlayer))
        } else {
            try notifyPlayer(message: Message.addAIPlayerFailed(), socket: socket)
        }
    }
    
    public func handleStartGame(_ socket: WebSocket) throws {
        if self.state != .created || self.players.count < 3 {
            try notifyPlayer(message: Message.startGameFailed(), socket: socket)
        }
        try self.newGame()
    }
    
    public func playerMadeDecision(playerID: String, decision: Bool) throws {
        try notifyPlayers(message: Message.informDecision(beLandlord: decision, playerID: playerID))
        let player: Player? = findPlayerWithID(playerID)
        player?.makeDecision(decision: decision)
        self.activePlayer = findPlayerWithNum(player?.getPlayerNum().getNext() ?? PlayerNum.none)
        
        if self.state == .choosingLandlord {
            if !(self.activePlayer?.hasMadeDecision() ?? false) {
                try notifyPlayers(message: Message.playerDecisionTurn(player: self.activePlayer))
            } else {
                try self.pillageLandlord()
            }
        } else {
            if !(self.activePlayer!.hasMadePillageDecision()) {
                if !(self.activePlayer!.wantToBeLandlord()) {
                    self.activePlayer?.makeDecision(decision: false)
                    self.activePlayer = findPlayerWithNum(self.activePlayer!.getPlayerNum().getNext())
                    if !(self.activePlayer!.hasMadePillageDecision()) {
                        try notifyPlayers(message: Message.playerPillageTurn(player: self.activePlayer))
                    } else {
                        try decideLandlord()
                    }
                } else {
                    try notifyPlayers(message: Message.playerPillageTurn(player: self.activePlayer))
                }
            } else {
                try decideLandlord()
            }
        }
    }
    
    public func playerMakePlay(_ id: String, cards: [Card]) throws {
        if !isCurrentPlayValid(cards: cards) {
            try notifyPlayers(message: Message.unknonError())
            self.abortGame()
        }
        let player: Player = findPlayerWithID(id)!
        self.currentPlay = checkPlay(cards: cards)
        self.lastPlayedCard = cards
        self.lastPlayedPlayer = player
        try player.makePlay(cards: cards)
        try self.notifyPlayers(message: Message.informPlay(player: player, cards: cards))
        self.activePlayer = self.findPlayerWithNum(player.getPlayerNum().getNext())
        try self.runGame()
    }
    
    // May add more code to handle different type of error later on
    public func handleError(_ error: Error?) {
        self.abortGame()
    }
    
    // TO DO
    // abort the game sine an unknow error has occured, or when no one chooses to be the landlord
    private func abortGame() {
        
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
        deck.newGame()

        self.state = .started
        self.landlord = nil
        self.currentPlay = Play.none
        
        for player in self.players {
            player.startNewGame(cards: deck.getPlayerCard(playerNum: player.getPlayerNum()))
            try self.notifyPlayer(message: Message.startGame(player: player, cards: deck.getPlayerCard(playerNum: player.getPlayerNum())), socket: player.getSocket())
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
    
    private func getWinner()->String? {
        if self.state != .inProgress {
            return nil
        } else {
            if landlord?.getNumCard() == 0 {
                return "Landlord"
            } else {
                return "Farmer"
            }
        }
    }
    
    private func runGame() throws {
        self.state = .inProgress
        if isGameOver() {
            self.gameEnded()
        } else {
            try notifyPlayers(message: Message.playerTurn(player: self.activePlayer))
        }
    }
    
    private func gameEnded() {
        print("game has ended")
    }
    
    private func electLandlord() throws {
        self.state = .choosingLandlord
        
        let rand = Int.random(in: 0...2)
        self.activePlayer = rand == 0 ? self.players[0] : (rand == 1 ? self.players[1] : self.players[2])
        
        try notifyPlayers(message: Message.playerDecisionTurn(player: self.activePlayer))
    }
    
    private func pillageLandlord() throws {
        self.state = .pillagingLandlord
        
        var willingPlayers: [Player] = []
        for player in self.players {
            if player.wantToBeLandlord() {
                willingPlayers.append(player)
            }
        }
        
        if willingPlayers.count < 2 {
            try decideLandlord()
        } else {
            if !self.activePlayer!.wantToBeLandlord() {
                self.activePlayer = findPlayerWithNum(self.activePlayer?.getPlayerNum().getNext() ?? PlayerNum.none)
            }
            try notifyPlayers(message: Message.playerPillageTurn(player: self.activePlayer))
        }
    }
    
    private func decideLandlord() throws {
        for _ in 0..<3 {
            if self.activePlayer!.wantToBeLandlord() {
                try self.notifyLandlord(self.activePlayer!)
                return
            }
            self.activePlayer = findPlayerWithNum(self.activePlayer!.getPlayerNum().getNext())
        }
        try self.startNewGameSinceNoOneChooseToBeLandlord()
    }
    
    private func notifyPlayer(message: Message, socket: WebSocket?) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        socket?.sendStringMessage(string: jsonString, final: true, completion: {
            print("did send message: \(message.type)")
        })
    }
    
    private func notifyPlayers(message: Message) throws {
        try self.players.forEach({
            try self.notifyPlayer(message: message, socket: $0.getSocket())
        })
    }
    
    private func handleJoin(_ player: Player) throws -> Bool {
        if self.players.count > 3 {
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
        try notifyPlayers(message: Message.informLandlord(playerID: landlord.id, landlordCards: landlordCards))
        try self.runGame()
    }
    
    // TO DO
    private func startNewGameSinceNoOneChooseToBeLandlord() throws {
        try self.newGame()
    }
    
    private func isCurrentPlayValid(cards: [Card]) -> Bool {
        let cardPlay = checkPlay(cards: cards)
        
        if self.activePlayer == self.lastPlayedPlayer || self.lastPlayedPlayer == nil {
            return cardPlay != .none && cardPlay != .invalid
        } else if cardPlay == .rocket || (cardPlay == .bomb && self.currentPlay != . bomb && self.currentPlay != .rocket) {
            return true
        } else if cardPlay == .none || cardPlay == .invalid || (self.currentPlay != .none && self.currentPlay != cardPlay) {
            return false
        } else if (self.currentPlay == .none) {
            return true
        }
        
        switch currentPlay {
        case .solo, .pair, .trio, .bomb:
            return cards[0] > self.lastPlayedCard[0]
        case .soloChain, .pairChain, .airplane:
            return cards.max()! > self.lastPlayedCard.max()!
        case .trioPlusPair, .trioPlusSolo, .airplanePlusPair, .airplanePlusSolo:
            let cards_parsed = parseCards(cards: cards)
            let lastPlayedCard_parsed = parseCards(cards: lastPlayedCard)
            
            var cardTrio: Card = NullCard.shared
            var lastTrio: Card = NullCard.shared
            for card in lastPlayedCard_parsed.numCards {
                if lastPlayedCard_parsed.card_count[card.getNum()]! == 3 {
                    lastTrio = card
                    break
                }
            }
            for card in cards_parsed.numCards {
                if cards_parsed.card_count[card.getNum()]! == 3 {
                    cardTrio = card
                    break
                }
            }
            return cardTrio > lastTrio
        case .spaceShuttle, .spaceShuttlePlusFourPair, .spaceShuttlePlusFourSolo, .bombPlusDualSolo, .bombPlusDualPair:
            let cards_parsed = parseCards(cards: cards)
            let lastPlayedCard_parsed = parseCards(cards: lastPlayedCard)
            
            var cardBomb: Card = NullCard.shared
            var lastBomb: Card = NullCard.shared
            for card in lastPlayedCard_parsed.numCards {
                if lastPlayedCard_parsed.card_count[card.getNum()]! == 4 {
                    cardBomb = card
                    break
                }
            }
            for card in cards_parsed.numCards {
                if cards_parsed.card_count[card.getNum()]! == 4 {
                    lastBomb = card
                    break
                }
            }
            return cardBomb > lastBomb
        default:
            return false
        }
    }
}

