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
    let beLandlordButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let notBeLandlordButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let player1CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    let player2CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    let player3CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    
    let playButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: SKTexture(imageNamed: "disabledBtn"))
    let hintButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let passButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: SKTexture(imageNamed: "disabledBtn"))
    
    let playerCardContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))

    let player2Card = SKSpriteNode(imageNamed: "back")
    let player2CardCount = SKLabelNode(text: "17")
    let player3Card = SKSpriteNode(imageNamed: "back")
    let player3CardCount = SKLabelNode(text: "17")
    let gameOverMsg = SKLabelNode(text: "")
    
    let LandlordCard1 = SKSpriteNode(imageNamed: "back_small")
    let LandlordCard2 = SKSpriteNode(imageNamed: "back_small")
    let LandlordCard3 = SKSpriteNode(imageNamed: "back_small")
    let countDownLabel = SKLabelNode(text: "0")
    let landlordLabel = SKLabelNode(text: "L")
    
    private var countDown: Int = 0
    private var timer: Timer? = nil
    private var game: DouDiZhuGame? = nil
    
    override init(size: CGSize) {
        super.init(size: size)
        self.countDown = 0
        self.timer = nil
        self.game = DouDiZhuGame(scene: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player2CardCount.fontColor = UIColor.black
        player3CardCount.fontColor = UIColor.black
        
        gameOverMsg.position = CGPoint(x:self.frame.midX - 25, y: self.frame.midY + 75)
        gameOverMsg.fontColor = UIColor.black
        gameOverMsg.fontSize = 50
        self.addChild(gameOverMsg)
        gameOverMsg.isHidden = true
        
        countDownLabel.name = "countDownLabel"
        countDownLabel.fontColor = UIColor.black
        countDownLabel.position = CGPoint(x: 600, y: 150)
        countDownLabel.isHidden = true
        self.addChild(countDownLabel)
        
        landlordLabel.name = "landlordLabel"
        landlordLabel.fontColor = UIColor.black
        landlordLabel.fontSize = 30
        landlordLabel.isHidden = true
        self.addChild(landlordLabel)
        
        setButtonAttributes()
        
        self.addChild(startGameButton)
        self.addChild(beLandlordButton)
        self.addChild(notBeLandlordButton)
        self.addChild(playButton)
        self.addChild(hintButton)
        self.addChild(passButton)
        self.addChild(playerCardContainer)
        
        self.addChild(player1CurrentPlay)
        self.addChild(player2CurrentPlay)
        self.addChild(player3CurrentPlay)
        
        player2Card.name = "player2Card"
        player2Card.position = CGPoint(x: self.frame.minX + 75, y: CGFloat(270))
        player2CardCount.name = "player2CardCount"
        player2CardCount.position = CGPoint(x: self.frame.minX + 75, y: CGFloat(200))
        player3Card.name = "player3Card"
        player3Card.position = CGPoint(x: self.frame.maxX - 75, y: CGFloat(270))
        player3CardCount.name = "player3CardCount"
        player3CardCount.position = CGPoint(x: self.frame.maxX - 75, y: CGFloat(200))
        
        self.addChild(player2Card)
        self.addChild(player2CardCount)
        self.addChild(player3Card)
        self.addChild(player3CardCount)
        
        LandlordCard1.name = "LandlordCard1"
        LandlordCard1.position = CGPoint(x: size.width / 2 - 50, y: CGFloat(340))
        LandlordCard2.name = "LandlordCard2"
        LandlordCard2.position = CGPoint(x: size.width / 2, y: CGFloat(340))
        LandlordCard3.name = "LandlordCard3"
        LandlordCard3.position = CGPoint(x: size.width / 2 + 50, y: CGFloat(340))
        
        self.addChild(LandlordCard1)
        self.addChild(LandlordCard2)
        self.addChild(LandlordCard3)
        
        startGameButton.isHidden = false
        cleanTable()
    }
    
    func cleanTable() {
        playerCardContainer.removeAllChildren()
        playerCardContainer.isHidden = true
        
        player2Card.isHidden = true
        player3Card.isHidden = true
        player2CardCount.isHidden = true
        player3CardCount.isHidden = true
        
        LandlordCard1.isHidden = true
        LandlordCard2.isHidden = true
        LandlordCard3.isHidden = true
        
        hideBeLandlordActionButtons()
        hidePlayButtons()
    }
    
    func setButtonAttributes() {
        startGameButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.startGame))
        startGameButton.setButtonLabel(title: "Start game!", font: "Arial", fontSize: 12)
        startGameButton.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        startGameButton.size = CGSize(width: 100, height: 20)
        startGameButton.zPosition = 1
        startGameButton.name = "startGameBtn"
        
        beLandlordButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.beLandlordButtonClicked))
        beLandlordButton.setButtonLabel(title: "Be landlord!", font: "Arial", fontSize: 12)
        beLandlordButton.position = CGPoint(x: self.frame.midX - 100,y: 130)
        beLandlordButton.size = CGSize(width: 150, height: 30)
        beLandlordButton.zPosition = 1
        beLandlordButton.name = "beLandlordBtn"
        
        notBeLandlordButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.notBeLandlordButtonClicked))
        notBeLandlordButton.setButtonLabel(title: "Be a farmer", font: "Arial", fontSize: 12)
        notBeLandlordButton.position = CGPoint(x: self.frame.midX+100,y: 130)
        notBeLandlordButton.size = CGSize(width: 150, height: 30)
        notBeLandlordButton.zPosition = 1
        notBeLandlordButton.name = "notBeLandlordBtn"

        playButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.playButtonClicked))
        playButton.setButtonLabel(title: "Play", font: "Arial", fontSize: 12)
        playButton.position = CGPoint(x: self.frame.midX - 150,y: 130)
        playButton.size = CGSize(width: 100, height: 30)
        playButton.zPosition = 1
        playButton.name = "playBtn"

        hintButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.hintButtonClicked))
        hintButton.setButtonLabel(title: "Hint", font: "Arial", fontSize: 12)
        hintButton.position = CGPoint(x: self.frame.midX,y: 130)
        hintButton.size = CGSize(width: 100, height: 30)
        hintButton.zPosition = 1
        hintButton.name = "hintBtn"

        passButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.passButtonClicked))
        passButton.setButtonLabel(title: "Pass", font: "Arial", fontSize: 12)
        passButton.position = CGPoint(x: self.frame.midX + 150,y: 130)
        passButton.size = CGSize(width: 100, height: 30)
        passButton.zPosition = 1
        passButton.name = "passBtn"
    }
    
    @objc func startGame() {
        resetTable()
        game!.newGame()
        game!.startGame()
    }
    
    func displayPlayerCards(cards: [CardButtonNode]) {
        for i in 0..<cards.count {
            self.playerCardContainer.addChild(cards[i])
        }
    }
    
    func resetTimer(interval: Int) {
        self.countDown = interval
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.timePassed), userInfo: nil, repeats: true)
        countDownLabel.isHidden = false
        countDownLabel.text = String(countDown)
    }
    
    func revealLandloardCard(cards: [Card]) {
        LandlordCard1.texture = SKTexture(imageNamed: cards[0].getIdentifier())
        LandlordCard2.texture = SKTexture(imageNamed: cards[1].getIdentifier())
        LandlordCard3.texture = SKTexture(imageNamed: cards[2].getIdentifier())
    }
    
    func hideBeLandlordActionButtons() {
        beLandlordButton.isHidden = true
        notBeLandlordButton.isHidden = true
    }
    
    func showBeLandlordActionButtons() {
        beLandlordButton.isHidden = false
        notBeLandlordButton.isHidden = false
    }
    
    func hidePlayButtons() {
        playButton.isHidden = true
        hintButton.isHidden = true
        passButton.isHidden = true
    }
    
    func showPlayButtons() {
        playButton.isHidden = false
        hintButton.isHidden = false
        passButton.isHidden = false
    }
    
    func disablePlayButton() {
        playButton.isEnabled = false
    }
    
    func enablePlayButton() {
        playButton.isEnabled = true
    }
    
    func disablePassButton() {
        passButton.isEnabled = false
    }
    
    func enablePassButton() {
        passButton.isEnabled = true
    }
    
    func setBeLandlordButtonText(pillage: Bool) {
        if pillage {
            beLandlordButton.setButtonLabel(title: "Pillage landlord!", font: "Arial", fontSize: 12)
        } else {
            beLandlordButton.setButtonLabel(title: "Be landlord!", font: "Arial", fontSize: 12)
        }
    }
    
    func resetTable() {
        gameOverMsg.isHidden = true
        startGameButton.isHidden = true
        landlordLabel.isHidden = true
        playerCardContainer.isHidden = false
        playerCardContainer.removeAllChildren()
        
        LandlordCard1.texture = SKTexture(imageNamed: "back_small")
        LandlordCard2.texture = SKTexture(imageNamed: "back_small")
        LandlordCard3.texture = SKTexture(imageNamed: "back_small")
        
        LandlordCard1.isHidden = false
        LandlordCard2.isHidden = false
        LandlordCard3.isHidden = false
        
        player2CardCount.text = String(17)
        player3CardCount.text = String(17)
        
        player2Card.isHidden = false
        player3Card.isHidden = false
        player2CardCount.isHidden = false
        player3CardCount.isHidden = false
        
        self.clearCurrentPlay()
    }
    
    @objc func timePassed() {
        countDown -= 1
        countDownLabel.text = String(countDown)
        if countDown < 0 {
            self.game?.timeout()
            self.userMadeChoice()
        }
    }
    
    func userMadeChoice() {
        timer!.invalidate()
        countDownLabel.isHidden = true
    }
    
    @objc func beLandlordButtonClicked() {
        self.userMadeChoice()
        self.hideBeLandlordActionButtons()
        self.game!.playerChooseToBeLandlord()
    }
    
    @objc func notBeLandlordButtonClicked() {
        self.userMadeChoice()
        self.hideBeLandlordActionButtons()
        self.game!.playerChooseToBeFarmer()
    }
    
    func refreshScene() {
        self.view?.setNeedsLayout()
        self.view?.layoutIfNeeded()
    }
    
    func startNewGameSinceNoPlayerChooseToBeLandlord() {
        print("new game started")
        startGame()
    }
    
    func getPlayerPlayDisplayPosition(playerNum: PlayerNum)->CGPoint {
        switch playerNum {
        case .one:
            return CGPoint(x: self.frame.midX, y: 180)
        case .two:
            return CGPoint(x: self.frame.minX + 150, y: 250)
        default:
            return CGPoint(x: self.frame.maxX - 150, y: 250)
        }
    }
    
    func displayPlayerDecision(playerNum: PlayerNum, decision: String) {
        var playerContainer: SKSpriteNode;
        switch playerNum {
        case .one:
            playerContainer = player1CurrentPlay
        case .two:
            playerContainer = player2CurrentPlay
        default:
            playerContainer = player3CurrentPlay
        }
        
        playerContainer.removeAllChildren()
        let display: SKLabelNode = SKLabelNode(text: decision)
        display.name = "display"
        display.fontColor = UIColor.black
        display.fontSize = 15
        display.position = self.getPlayerPlayDisplayPosition(playerNum: playerNum)
        playerContainer.addChild(display)
    }
    
    func displayPlayerPlay(playerNum: PlayerNum, cards: [Card]) {
        var playerContainer: SKSpriteNode;
        switch playerNum {
        case .one:
            playerContainer = player1CurrentPlay
        case .two:
            playerContainer = player2CurrentPlay
        default:
            playerContainer = player3CurrentPlay
        }
        
        playerContainer.removeAllChildren()
        let position = self.getPlayerPlayDisplayPosition(playerNum: playerNum)
        for i in 0..<cards.count {
            let card: SKSpriteNode = SKSpriteNode(imageNamed: cards[i].getIdentifier() + "_small")
            card.position = CGPoint(x: position.x + CGFloat((i - cards.count / 2) * 15), y:position.y)
            playerContainer.addChild(card)
        }
    }
    
    func updateLandlord(landlordNum: PlayerNum) {
        var position: CGPoint
        switch landlordNum {
        case .one:
            position = CGPoint(x: 150, y: 100)
        case .two:
            position = CGPoint(x: self.frame.minX + 75, y: 320)
            player2CardCount.text = String(game!.getPlayer2CardCount())
        default:
            position = CGPoint(x: self.frame.maxX - 75, y: 320)
            player3CardCount.text = String(game!.getPlayer3CardCount())
        }
        self.landlordLabel.position = position
        self.landlordLabel.isHidden = false
    }
    
    func clearCurrentPlay() {
        player1CurrentPlay.removeAllChildren()
        player2CurrentPlay.removeAllChildren()
        player3CurrentPlay.removeAllChildren()
    }
    
    @objc func playButtonClicked() {
        self.game!.playButtonClicked()
    }
    
    @objc func hintButtonClicked() {
        self.game!.hintButtonClicked()
    }
    
    @objc func passButtonClicked() {
        self.game!.passButtonClicked()
    }
    
    func gameOver() {
        gameOverMsg.text = self.game!.getWinner()! + " wins!"
        gameOverMsg.isHidden = false
        startGameButton.isHidden = false
    }
}
