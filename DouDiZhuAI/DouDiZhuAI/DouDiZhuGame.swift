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

class DouDiZhuGame {
    static let sharedInstace = DouDiZhuGame()
    static var gameScene: GameScene? = nil
    
    private (set) var client = DouDiZhuClient()
    private (set) var state: GameState = .disconnected
    private (set) var player: Player?
    private (set) var userSelectedCards:[Card] = []
    private (set) var playerCardButtons:[CardButtonNode] = []
    private (set) var currentPlay: Play = .none
    private (set) var otherPlayers: [String:PlayerNum] = [:]
    
    public func start() {
        self.client.delegate = self
        self.client.connect()
    }
    
    public func stop() {
        self.client.disconnect()
    }
    
    public func isConnected() -> Bool {
        return self.state != GameState.disconnected
    }
    
    public func letPlayerDecideLandlord() {
        //        if playerNum == 0 {
        //            if self.pillagingLandlord {
        //                self.gameScene.setBeLandlordButtonText(pillage: true)
        //            } else {
        //                self.gameScene.setBeLandlordButtonText(pillage: false)
        //            }
        //            self.gameScene.showBeLandlordActionButtons()
        //            self.waitForPlayerChoise()
        //        }
    }
    
    public func cardIsClicked(card: Card) {
        var isSelected: Bool = true
        
        for i in 0..<self.userSelectedCards.count {
            if card.getIdentifier() == self.userSelectedCards[i].getIdentifier() {
                self.userSelectedCards.remove(at: i)
                isSelected = false
                break
            }
        }
        
        if isSelected {
            self.userSelectedCards.append(card)
        }
        
        //        if currentPlayerNum == 0 {
        //            if isCurrentPlayValid(cards: self.userSelectedCards) {
        //                self.gameScene.enablePlayButton()
        //            }
        //        }
    }
    
    public func playerDecided(beLandlord: Bool) {
        self.client.informDecision(beLandlord: beLandlord, playerID: self.player?.id ?? "")
    }
    
    public func playButtonClicked() {
        if self.state != .active {
            return
        }
        
        let res = checkPlay(cards: self.userSelectedCards)
        if res == Play.invalid || res == Play.none {
            return
        } else if res != Play.bomb && res != Play.rocket && currentPlay != Play.none && res != currentPlay {
            return
        }
        if currentPlay == Play.none {
            currentPlay = res
        }
        
        DouDiZhuGame.gameScene?.displayPlayerPlay(playerNum: self.player!.getPlayerNum(), cards: self.userSelectedCards)
        
        for selected_card in self.userSelectedCards {
            for i in 0..<self.playerCardButtons.count {
                if self.playerCardButtons[i].getIdentifier() == selected_card.getIdentifier() {
                    self.playerCardButtons[i].removeFromParent()
                    self.playerCardButtons.remove(at: i)
                    break
                }
            }
        }
        
        self.userSelectedCards = []
        
        for i in 0..<self.playerCardButtons.count {
            playerCardButtons[i].position = CGPoint(x: 200 - (self.playerCardButtons.count - 17) * 13 + 25 * i, y: 50)
        }
    }
    
    public func hintButtonClicked() {
        for selected_card in self.userSelectedCards {
            for i in 0..<self.playerCardButtons.count {
                if self.playerCardButtons[i].getIdentifier() == selected_card.getIdentifier() {
                    self.playerCardButtons[i].CardClicked()
                }
            }
        }
        
        self.userSelectedCards = []
        
        let suggested_cards: [Card] = suggestPlay(playerCards: [], currentPlay: Play.none, lastPlayedCards: [NullCard()])
        
        if suggested_cards.count == 0 {
            self.passButtonClicked()
        }
        for selected_card in suggested_cards {
            for i in 0..<self.playerCardButtons.count {
                if self.playerCardButtons[i].getIdentifier() == selected_card.getIdentifier() {
                    self.playerCardButtons[i].CardClicked()
                    break
                }
            }
        }
        
        self.userSelectedCards = suggested_cards
    }
    
    public func passButtonClicked() {
        
    }
    
    public func timeOut() {
        
    }
    
    public func addAIPlayer() {
        self.client.addAIPlayer()
    }
    
    private func joinGame() {
        self.client.joinGame()
    }
    
    public func startGame() {
        self.client.startGame()
    }
    
    private func setExistingPlayer(playerIDs: [String]){
        for playerID in playerIDs {
            self.addNewPlayer(playerID: playerID)
        }
    }
    
    private func addNewPlayer(playerID: String) {
        let nextPlayerNum: PlayerNum = self.otherPlayers.count == 0 ? PlayerNum.two : PlayerNum.three
        otherPlayers[playerID] = nextPlayerNum
        DouDiZhuGame.gameScene?.newUserAdded(playerNum: nextPlayerNum)
        
        if self.otherPlayers.count == 2 {
            DouDiZhuGame.gameScene?.enableStartGameButton()
            DouDiZhuGame.gameScene?.disableAddAIButton()
        }
    }
    
    private func createPlayerCards() {
        let playerCards: [Card] = self.player?.getCards() ?? []
        for i in 0..<playerCards.count {
            let newCard = CardButtonNode(normalTexture: SKTexture(imageNamed: playerCards[i].getIdentifier()), card: playerCards[i], game: self)
            newCard.position = CGPoint(x: 200 - (playerCards.count - 17) * 13 + 25 * i, y: 50)
            self.playerCardButtons.append(newCard)
        }
        DouDiZhuGame.gameScene?.displayPlayerCards(cards: self.playerCardButtons)
    }
    
    private func getMessageToDisplay(type: MessageType) -> String {
        switch type {
        case .playerWantToBeFarmer, .playerWillNotPillageLandlord:
            return "Be a farmer"
        case .playerWantToBeLandlord:
            return "Be the landlord"
        case .playerWantToPillageLandlord:
            return "Pillage the landlord"
        default:
            return ""
        }
    }
    
    private func updateLandlordCardCount(num: PlayerNum) {
        DouDiZhuGame.gameScene?.updateLandlord(landlordNum: num)
    }
    
    private init() { /* singleton */ }
}

extension DouDiZhuGame: DouDiZhuClientDelegate {
    func clientDidDisconnect(error: Error?) {
        self.state = .disconnected
        if error != nil {
            DouDiZhuGame.gameScene?.showAlert(withTitle: "Connection failed", message: "Failed to connect to the server, please try again!")
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
            
            self.player = Player(id: playerID, num: PlayerNum.one)
            setExistingPlayer(playerIDs: message.existingPlayers)
            
            DouDiZhuGame.gameScene?.enterGameScene()
            return
        case .newUserJoined:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            // when current user join the game, the message will be sent to everyone, so current user will receive the message twice
            if playerID == self.player?.id {
                return
            }
            
            self.addNewPlayer(playerID: playerID)
            return
        case .addAIPlayerFailed:
            DouDiZhuGame.gameScene?.showAlert(withTitle: "Add AI player failed", message: "Failed to add AI player to the game, please try again!")
        case .joinGameFailed:
            DouDiZhuGame.gameScene?.showAlert(withTitle: "Join failed", message: "Failed to join the game, please try again")
        case .startGameFailed:
            DouDiZhuGame.gameScene?.showAlert(withTitle: "Start failed", message: "Failed to start the game, please try again")
        case .gameStarted:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            DouDiZhuGame.gameScene?.resetTable()
            if playerID != self.player?.id {
                print("The given player id doesn't match current player id, this should never happen")
                return
            }
            self.player?.startNewGame(cards: message.cards)
            self.createPlayerCards()
        case .playerDecisionTurn:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            if playerID != self.player?.id {
                DouDiZhuGame.gameScene?.showCountDownLabel(self.otherPlayers[playerID] ?? PlayerNum.one)
            } else {
                DouDiZhuGame.gameScene?.showBeLandlordActionButtons()
                DouDiZhuGame.gameScene?.showCountDownLabel(PlayerNum.one)
            }
            
        case .playerWantToBeLandlord, .playerWantToBeFarmer:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            let playerNum = (playerID == self.player?.id) ? PlayerNum.one : (self.otherPlayers[playerID] ?? PlayerNum.one)
            DouDiZhuGame.gameScene?.displayPlayerDecision(playerNum: playerNum, decision: self.getMessageToDisplay(type: message.type))
        case .informLandlord:
            guard let playerID = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            DouDiZhuGame.gameScene?.revealLandloardCard(cards: message.cards)
            if playerID == self.player?.id {
                self.player?.addLandlordCard(newCards: message.cards)
                self.createPlayerCards()
            }
            self.updateLandlordCardCount(num: (playerID == self.player?.id ? PlayerNum.one : self.otherPlayers[playerID] ?? PlayerNum.one))
        case .gameEnd:
            if let winningPlayer = message.playerID {
                self.state = (winningPlayer == self.player?.id) ? .playerWon : .playerLost
            } else {
                self.state = .draw
            }
        case .playerTurn:
            guard let activePlayer = message.playerID else {
                print("No player ID is provided within the message, this should never happen")
                return
            }
            
            if activePlayer == self.player?.id {
                self.state = .active
            } else {
                self.state = .waiting
            }
        default: break
        }
    }
}
