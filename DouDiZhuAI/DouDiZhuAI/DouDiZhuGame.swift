//
//  DouDiZhuGame.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import SpriteKit
import Foundation

class DouDiZhuGame {
    private var deck: Deck = Deck()
    private var playerCardArr: [[Card]] = [[]]
    private var player1: HumanPlayer = HumanPlayer(num: PlayerNum.one)
    private var player2: ComputerPlayer = ComputerPlayer(num: PlayerNum.two)
    private var player3: ComputerPlayer = ComputerPlayer(num: PlayerNum.three)
    private var landlord: Player?
    private var gameScene: GameScene
    private var pillagingLandlord: Bool
    private var beLandlordDecision:[Bool]
    private var pillageLandlordDecision:[Bool]
    private var currentPlayerNum:Int
    
    init(scene: GameScene) {
        self.landlord = nil
        self.gameScene = scene
        self.pillagingLandlord = false
        self.beLandlordDecision = [false, false, false]
        self.pillageLandlordDecision = [false, false, false]
        self.currentPlayerNum = -1
    }
    
    func newGame() {
        let newCards = deck.newGame()
        self.landlord = nil
        self.pillagingLandlord = false
        self.beLandlordDecision = [false, false, false]
        self.pillageLandlordDecision = [false, false, false]
        self.currentPlayerNum = -1
        splitCards(cards: newCards)
        
        player1.startNewGame(cards: playerCardArr[0])
        player2.startNewGame(cards: playerCardArr[1])
        player3.startNewGame(cards: playerCardArr[2])
    }
    
    func splitCards(cards: [Card]) {
        var cardOwner = Array(repeating: 0, count: 17)
        cardOwner.append(contentsOf: Array(repeating: 1, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 2, count: 17))
        cardOwner.append(contentsOf: Array(repeating: 3, count: 3))
        
        cardOwner.shuffle()
        playerCardArr = Array(repeating: [], count: 4)
        
        for i in 0..<cardOwner.count {
            playerCardArr[cardOwner[i]].append(cards[i])
        }
        
        for i in 0..<playerCardArr.count {
            playerCardArr[i].sort()
        }
    }
    
    func startGame() {
        self.chooseLandlord()
    }
    
    func runGame() {
        
    }
    
    func getPlayerCards()->[Card] {
        return self.player1.getCards()
    }
    
    func getLandlordCards()->[Card] {
        return self.playerCardArr[3]
    }
    
    func isGameOver()->Bool {
        return player1.getNumCard() == 0 ||
               player2.getNumCard() == 0 ||
               player3.getNumCard() == 0
    }
    
    func getWinner()->String? {
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
    
    func getPlayer2CardCount()->Int {
        return self.player2.getNumCard()
    }
    
    func getPlayer3CardCount()->Int {
        return self.player3.getNumCard()
    }
    
    func chooseLandlord() {
        self.currentPlayerNum = Int.random(in: 0...2)
        if currentPlayerNum == 0 {
            letPlayerDecideLandlord(playerNum: 0)
        } else if currentPlayerNum == 1 {
            letPlayerDecideLandlord(playerNum: 1)
            self.beLandlordDecision[1] = true
            let decision = player2.wantToBeLandlord()
            if decision {
                self.pillagingLandlord = true
                self.pillageLandlordDecision[2] = true
            } else {
                self.beLandlordDecision[2] = true
            }
            letPlayerDecideLandlord(playerNum: 2)
            if !decision && player3.wantToBeLandlord() {
                self.pillagingLandlord = true
            }
            letPlayerDecideLandlord(playerNum: 0)
        } else {
            letPlayerDecideLandlord(playerNum: 2)
            self.beLandlordDecision[2] = true
            if player3.wantToBeLandlord() {
                self.pillagingLandlord = true
            }
            letPlayerDecideLandlord(playerNum: 0)
        }
    }
    
    func letPlayerDecideLandlord(playerNum: Int) {
        if playerNum == 0 {
            if self.pillagingLandlord {
                self.gameScene.setBeLandlordButtonText(pillage: true)
            } else {
                self.gameScene.setBeLandlordButtonText(pillage: false)
            }
            self.gameScene.showBeLandlordActionButtons()
            self.waitForPlayerChoise()
        } else if playerNum == 1 {
            var decision: Bool
            var text: String
            if self.pillagingLandlord {
                player2.chooseToPillageLandlord()
                decision = player2.wantToPillageLandlord()
                text = "Pillage landlord"
            } else {
                player2.chooseToBeLandlord()
                decision = player2.wantToBeLandlord()
                text = "Be landlord"
            }
            self.gameScene.displayPlayerDecision(playerNum: 1, decision: decision ? text : "Be a farmer")
        } else {
            var decision: Bool
            var text: String
            if self.pillagingLandlord {
                player3.chooseToPillageLandlord()
                decision = player3.wantToPillageLandlord()
                text = "Pillage landlord"
            } else {
                player3.chooseToBeLandlord()
                decision = player3.wantToBeLandlord()
                text = "Be landlord"
            }
            self.gameScene.displayPlayerDecision(playerNum: 2, decision: decision ? text : "Be a farmer")
        }
    }
    
    func waitForPlayerChoise() {
        self.gameScene.resetTimer(interval: 30)
    }
    
    func timeout() {
        if self.landlord == nil {
            self.playerChooseToBeFarmer()
        } else {
            player1.pass()
        }
    }
    
    func playerChooseToBeLandlord() {
        self.gameScene.displayPlayerDecision(playerNum: 0, decision: self.pillagingLandlord ? "Pillage landlord" : "Be landlord")
        if !self.pillagingLandlord {
            player1.decideToBeLandlord(decision: true)
            self.pillagingLandlord = true
            self.beLandlordDecision[0] = true
            if self.beLandlordDecision[1] && self.beLandlordDecision[2] {
                // since it's not pillaging landlord, so any of the two previous player must decide to not be the landlord as if they have decided, so current player can be safely picked as landlord
                self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
            } else {
                if self.beLandlordDecision[2] { // player 3 has decided but it's not in the pillaging process so player 3 must have decided to not be the landlord
                    self.letPlayerDecideLandlord(playerNum: 1)
                    let decision = player2.wantToPillageLandlord()
                    if !decision {
                        self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
                    } else {
                        self.letPlayerDecideLandlord(playerNum: 1) // if player 2 wants to pillage landlord, then player 1 has to choose if he wants to pillage again
                    }
                } else { // player 3 has not decided as well, so only player 1 has made the choice
                    self.letPlayerDecideLandlord(playerNum: 1)
                    self.letPlayerDecideLandlord(playerNum: 2)
                    
                    let player2_decision = player2.wantToPillageLandlord()
                    let player3_decision = player3.wantToPillageLandlord()
                    if !player2_decision && !player3_decision { // both two players don't want to pillage the landlord
                        self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
                    } else { // at least one of the player wants to pillage the landlord, so we need to let player 1 decide again if he wants to pillage the landlord
                        self.letPlayerDecideLandlord(playerNum: 0)
                    }
                }
            }
        } else {
            player1.decideToPillageLandlord(decision: true)
            self.pillageLandlordDecision[0] = true
            
            if self.pillageLandlordDecision[1] && self.pillageLandlordDecision[2] {
                self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
            } else if !self.pillageLandlordDecision[1] && self.pillageLandlordDecision[2] { // player 2 had not decided to pillage or not, player 3 did, if we are in this case, then player 2 must be the player who first wants to be the landlord
                letPlayerDecideLandlord(playerNum: 1)
                let decision = player2.wantToPillageLandlord()
                        
                if decision {
                    self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                } else if player3.wantToPillageLandlord() {
                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                } else {
                    self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
                }
            } else { // if we are here, then it means that both player2 and player 3 must have not decided yet, and the only possibility when we are in this case is that player 3 is the first one who decided to be the landlord
                letPlayerDecideLandlord(playerNum: 1)
                letPlayerDecideLandlord(playerNum: 2)
                let decision = player3.wantToPillageLandlord()
                    
                if decision {
                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                } else {
                    self.setLandlordAndStartGame(landlordNum: player1.getPlayerNum())
                }
            }
        }
    }
    
    func playerChooseToBeFarmer() {
        self.gameScene.displayPlayerDecision(playerNum: 0, decision: "Be a farmer")
        
        if !self.pillagingLandlord {
            player1.decideToBeLandlord(decision: false)
            self.beLandlordDecision[0] = true
            if self.beLandlordDecision[1] && self.beLandlordDecision[2] {
                // since it's not pillaging landlord, so any of the two previous player must decide to not be the landlord as if they have decided, so new game has to be started
                self.gameScene.startNewGameSinceNoPlayerChooseToBeLandlord()
            } else {
                if self.beLandlordDecision[2] {
                    self.letPlayerDecideLandlord(playerNum: 1)
                    let decision = player2.wantToBeLandlord()
                    if !decision {
                        self.gameScene.startNewGameSinceNoPlayerChooseToBeLandlord()
                    } else {
                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                    }
                } else { // player 3 has not decided as well, so only player 1 has made the choice
                    self.letPlayerDecideLandlord(playerNum: 1)
                    let player2_decision = player2.wantToBeLandlord()
                    var player3_decision: Bool
                    if player2_decision {
                        self.pillagingLandlord = true
                        self.beLandlordDecision[1] = true
                        player3.chooseToPillageLandlord()
                        player3_decision = player3.wantToPillageLandlord()
                        if !player3_decision {
                            self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                        } else {
                            player2.chooseToPillageLandlord()
                            let player2_decision = player2.wantToPillageLandlord()
                            if player2_decision {
                                self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                            } else {
                                self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                            }
                        }
                    } else {
                        player3.chooseToBeLandlord()
                        player3_decision = player3.wantToBeLandlord()
                        if !player3_decision {
                            self.gameScene.startNewGameSinceNoPlayerChooseToBeLandlord()
                        } else {
                            self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                        }
                    }
                }
            }
        } else {
            player1.decideToPillageLandlord(decision: false)
            self.pillageLandlordDecision[0] = true
            
            if self.pillageLandlordDecision[2] && !self.pillageLandlordDecision[1] {
                let player3_decision = player3.wantToPillageLandlord()
                if !player3_decision {
                    self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                } else {
                    letPlayerDecideLandlord(playerNum: 1)
                    let player2_decision = player2.wantToPillageLandlord()
                    if player2_decision {
                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                    } else {
                        self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                    }
                }
            } else {
                letPlayerDecideLandlord(playerNum: 1)
                let player2_decision = player2.wantToPillageLandlord()
                if !player2_decision {
                    self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                } else {
                    letPlayerDecideLandlord(playerNum: 2)
                    let player3_decision = player3.wantToPillageLandlord()
                    if player3_decision {
                        self.setLandlordAndStartGame(landlordNum: player3.getPlayerNum())
                    } else {
                        self.setLandlordAndStartGame(landlordNum: player2.getPlayerNum())
                    }
                }
            }
        }
    }
    
    func setLandlordAndStartGame(landlordNum: PlayerNum) {
        var landlord: Player, currentPlayerNum: Int
        switch landlordNum {
        case .one:
            landlord = player1
            currentPlayerNum = 0
        case .two:
            landlord = player2
            currentPlayerNum = 1
        default:
            landlord = player3
            currentPlayerNum = 2
        }
        self.landlord = landlord
        self.landlord!.addLandlordCard(newCards: getLandlordCards())
        self.gameScene.updateLandlordCard(landlordNum: landlordNum)
        self.currentPlayerNum = currentPlayerNum
        self.runGame()
    }
}
