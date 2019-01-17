//
//  GameScene.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-12.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let startGameButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let instructionText = SKLabelNode(text: "Place your bet")
    let game = DouDiZhuGame()
    let playerCardContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    let cardBackImage = SKTexture(imageNamed: "back")
    let player2Card = SKSpriteNode(imageNamed: "back")
    let player2CardCount = SKLabelNode(text: "17")
    let player3Card = SKSpriteNode(imageNamed: "back")
    let player3CardCount = SKLabelNode(text: "17")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player2CardCount.fontColor = UIColor.black
        player3CardCount.fontColor = UIColor.black
        setButtonAttributes()
        self.addChild(startGameButton)
        self.addChild(playerCardContainer)
        
        player2Card.name = "player2Card"
        self.addChild(player2Card)
        player2Card.position = CGPoint(x: CGFloat(100), y: CGFloat(300))
        player2CardCount.name = "player2CardCount"
        self.addChild(player2CardCount)
        player2CardCount.position = CGPoint(x: CGFloat(100), y: CGFloat(230))
        player3Card.name = "player3Card"
        self.addChild(player3Card)
        player3Card.position = CGPoint(x: CGFloat(700), y: CGFloat(300))
        player3CardCount.name = "player3CardCount"
        self.addChild(player3CardCount)
        player3CardCount.position = CGPoint(x: CGFloat(700), y: CGFloat(230))
        cleanTable()
    }
    
    func cleanTable() {
        playerCardContainer.removeAllChildren()
        startGameButton.isHidden = false
        playerCardContainer.isHidden = true
    }
    
    func setButtonAttributes() {
        startGameButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.startGame))
        startGameButton.setButtonLabel(title: "Start game!", font: "Arial", fontSize: 12)
        startGameButton.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        startGameButton.size = CGSize(width: 100, height: 20)
        startGameButton.zPosition = 1
        startGameButton.name = "startGameBtn"
    }
    
    @objc func startGame() {
        startGameButton.isHidden = true
        playerCardContainer.isHidden = false
        game.newGame()
        let playerCards: [[Card]] = game.getPlayerCards()
        print(size.width, size.height)
        for i in 0..<playerCards[0].count {
            let newCard = CardButtonNode(normalTexture: SKTexture(imageNamed: playerCards[0][i].getIdentifier()))
            
            self.addChild(newCard)
            
            let x = 50 + 25 * i
            newCard.position = CGPoint(x: CGFloat(x), y: size.height/2)
        }
        
        
    }
    
    
    
    func selectCard(card: Card) {
        
    }
    
    func setup() {
        
    }
}
