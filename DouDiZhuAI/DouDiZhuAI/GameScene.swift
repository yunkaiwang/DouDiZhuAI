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
    let button: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let instructionText = SKLabelNode(text: "Place your bet")
    let game = DouDiZhuGame()
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setButtonAttributes()
        self.addChild(button)
    }
    
    func setButtonAttributes() {
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.startGame))
        button.setButtonLabel(title: "Start game!", font: "Arial", fontSize: 12)
        button.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        button.size = CGSize(width: 100, height: 20)
        button.zPosition = 1
        button.name = "startGameBtn"
    }
    
    @objc func startGame() {
        print("start game pressed")
        button.isHidden = true
        game.newGame()
    }
    
    func setup() {
        
    }
}
