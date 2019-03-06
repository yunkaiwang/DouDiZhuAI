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
    let welcomeLabel: SKLabelNode = SKLabelNode(text: "Welcome to Landlord game!")
    
    let addAIPlayerButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let startGameButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    
    let joinGameButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let beLandlordButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let beFarmerButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let player1CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    let player2CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    let player3CurrentPlay = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))
    
    let playButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: SKTexture(imageNamed: "disabledBtn"))
    let hintButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: nil)
    let passButton: FTButtonNode = FTButtonNode(normalTexture: SKTexture(imageNamed: "btn"), selectedTexture: SKTexture(imageNamed: "selectedBtn"), disabledTexture: SKTexture(imageNamed: "disabledBtn"))
    let alert: UIAlertView = UIAlertView(title: nil, message: nil, delegate: nil, cancelButtonTitle: "OK")
    
    let playerCardContainer = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 100))

    let player2Card = SKSpriteNode(imageNamed: "back")
    let player2CardCount = SKLabelNode(text: "17")
    let player3Card = SKSpriteNode(imageNamed: "back")
    let player3CardCount = SKLabelNode(text: "17")
    let gameOverMsg = SKLabelNode(text: "")
    let player2Status = SKLabelNode(text: "No Player Yet")
    let player3Status = SKLabelNode(text: "No Player Yet")
    
    let LandlordCard1 = SKSpriteNode(imageNamed: "back_small")
    let LandlordCard2 = SKSpriteNode(imageNamed: "back_small")
    let LandlordCard3 = SKSpriteNode(imageNamed: "back_small")
    let countDownLabel = SKLabelNode(text: "0")
    let landlordLabel = SKLabelNode(text: "L")
    
    private var countDown: Int = 0
    private var timer: Timer? = nil
    public static var gameController: UIViewController?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.countDown = 0
        self.timer = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLabelNodeAttr(node: SKLabelNode, name: String?, color: UIColor?, pos: CGPoint, size: CGFloat?, isHidden: Bool) {
        node.name = name
        node.fontColor = color
        node.position = pos
        node.fontSize = size ?? node.fontSize
        node.isHidden = isHidden
        self.addChild(node)
    }
    
    private func setSpritNodeAttr(node: SKSpriteNode, name: String?, pos: CGPoint) {
        node.name = name
        node.position = pos
        self.addChild(node)
    }
    
    private func setButtonAttributes() {
        self.setButtonNodeAttr(node: joinGameButton, title: "Join game!", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX - 25,y: self.frame.midY), size: CGSize(width: 100, height: 30), zPosition: nil, name: "joinGameBtn", selector: #selector(GameScene.joinGame), enable: true)
        self.setButtonNodeAttr(node: beLandlordButton, title: "Be landlord!", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX - 100,y: 130), size: CGSize(width: 150, height: 30), zPosition: nil, name: "beLandlordBtn", selector: #selector(GameScene.beLandlordButtonClicked), enable: false)
        self.setButtonNodeAttr(node: beFarmerButton, title: "Be a farmer", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX+100,y: 130), size: CGSize(width: 150, height: 30), zPosition: nil, name: "beFarmerBtn", selector: #selector(GameScene.beFarmerButtonClicked), enable: false)
        self.setButtonNodeAttr(node: playButton, title: "Play", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX - 150,y: 130), size: CGSize(width: 100, height: 30), zPosition: nil, name: "playBtn", selector: #selector(GameScene.playButtonClicked), enable: false)
        self.setButtonNodeAttr(node: hintButton, title: "Hint", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX,y: 130), size: CGSize(width: 100, height: 30), zPosition: nil, name: "hintBtn", selector: #selector(GameScene.hintButtonClicked), enable: false)
        self.setButtonNodeAttr(node: passButton, title: "Pass", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX + 150,y: 130), size: CGSize(width: 100, height: 30), zPosition: nil, name: "passBtn", selector: #selector(GameScene.passButtonClicked), enable: false)
        self.setButtonNodeAttr(node: addAIPlayerButton, title: "Add AI Player", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX - 25 ,y: 220), size: CGSize(width: 100, height: 30), zPosition: nil, name: "passBtn", selector: #selector(GameScene.addAIPlayer), enable: true)
        self.setButtonNodeAttr(node: startGameButton, title: "Start Game!", font: nil, fontSize: nil, pos: CGPoint(x: self.frame.midX - 25 ,y: 150), size: CGSize(width: 100, height: 30), zPosition: nil, name: "passBtn", selector: #selector(GameScene.startGame), enable: false)
    }
    
    private func setButtonNodeAttr(node: FTButtonNode, title: NSString, font: String?, fontSize: CGFloat?, pos: CGPoint, size: CGSize, zPosition: CGFloat?, name: String, selector: Selector, enable: Bool?) {
        node.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: selector)
        node.setButtonLabel(title: title, font: font ?? "Arial", fontSize: fontSize ?? 12)
        node.position = pos
        node.size = size
        node.isEnabled = enable ?? true
        node.zPosition = zPosition ?? 1
        node.name = name
        self.addChild(node)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        setLabelNodeAttr(node: welcomeLabel, name: "welcomeLabel", color: UIColor.black, pos: CGPoint(x:self.frame.midX - 25, y: self.frame.midY + 75), size: 50, isHidden: true)
        setLabelNodeAttr(node: gameOverMsg, name: "gameOverMsg", color: UIColor.black, pos: CGPoint(x:self.frame.midX - 25, y: self.frame.midY + 75), size: 50, isHidden: true)
        setLabelNodeAttr(node: countDownLabel, name: "countDownLabel", color: UIColor.black, pos: CGPoint(x: 600, y: 150), size: nil, isHidden: true)
        setLabelNodeAttr(node: landlordLabel, name: "landlordLabel", color: UIColor.black, pos: CGPoint(x: 600, y: 150), size: 30, isHidden: true)
        setLabelNodeAttr(node: player2CardCount, name: "player2CardCount", color: UIColor.black, pos: CGPoint(x: self.frame.minX + 75, y: CGFloat(200)), size: nil, isHidden: true)
        setLabelNodeAttr(node: player3CardCount, name: "player3CardCount", color: UIColor.black, pos: CGPoint(x: self.frame.maxX - 75, y: CGFloat(200)), size: nil, isHidden: true)
        setLabelNodeAttr(node: player2Status, name: "player2Status", color: UIColor.black, pos: CGPoint(x: self.frame.minX + 75, y: CGFloat(320)), size: 20, isHidden: true)
        setLabelNodeAttr(node: player3Status, name: "player3Status", color: UIColor.black, pos: CGPoint(x: self.frame.maxX - 75, y: CGFloat(320)), size: 20, isHidden: true)
        
        setSpritNodeAttr(node: player2Card, name: "player2Card", pos: CGPoint(x: self.frame.minX + 75, y: CGFloat(270)))
        setSpritNodeAttr(node: player3Card, name: "player3Card", pos: CGPoint(x: self.frame.maxX - 75, y: CGFloat(270)))
        setSpritNodeAttr(node: LandlordCard1, name: "LandlordCard1", pos: CGPoint(x: size.width / 2 - 50, y: CGFloat(340)))
        setSpritNodeAttr(node: LandlordCard2, name: "LandlordCard2", pos: CGPoint(x: size.width / 2, y: CGFloat(340)))
        setSpritNodeAttr(node: LandlordCard3, name: "LandlordCard3", pos: CGPoint(x: size.width / 2 + 50, y: CGFloat(340)))
        setButtonAttributes()
        
        self.addChild(playerCardContainer)
        self.addChild(player1CurrentPlay)
        self.addChild(player2CurrentPlay)
        self.addChild(player3CurrentPlay)
        
        alert.delegate = self
        joinGameButton.isHidden = false
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
        
        addAIPlayerButton.isHidden = true
        startGameButton.isHidden = true
        hideBeLandlordActionButtons()
        hidePlayButtons()
    }
    
    @objc func joinGame() {
        DouDiZhuGame.sharedInstace.start()
    }
    
    func enterGameScene() {
//        resetTable()
        joinGameButton.isHidden = true
        welcomeLabel.isHidden = false
        player2Status.isHidden = false
        player3Status.isHidden = false
        addAIPlayerButton.isHidden = false
        startGameButton.isHidden = false
    }
    
    public func newUserAdded(playerNum: PlayerNum) {
        switch playerNum {
        case .three:
            player3Status.text = "READY!"
            return
        case .two:
            player2Status.text = "READY!"
            return
        default:
            print("New user should never get assigned with player number other than 2 or 3, this should never happen")
            return
        }
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
        beFarmerButton.isHidden = true
    }
    
    func showBeLandlordActionButtons() {
        beLandlordButton.isHidden = false
        beFarmerButton.isHidden = false
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
        hidePlayButtons()
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
    
    func userMadeChoice() {
        timer!.invalidate()
        countDownLabel.isHidden = true
    }
    
    func refreshScene() {
        self.view?.setNeedsLayout()
        self.view?.layoutIfNeeded()
    }
    
    func startNewGameSinceNoPlayerChooseToBeLandlord() {
        
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
//            player2CardCount.text = String(game!.getPlayer2CardCount())
        default:
            position = CGPoint(x: self.frame.maxX - 75, y: 320)
//            player3CardCount.text = String(game!.getPlayer3CardCount())
        }
        self.landlordLabel.position = position
        self.landlordLabel.isHidden = false
    }
    
    func clearCurrentPlay() {
        player1CurrentPlay.removeAllChildren()
        player2CurrentPlay.removeAllChildren()
        player3CurrentPlay.removeAllChildren()
    }
    
    func clearCurrentPlayerPlay(currentPlayerNum: Int) {
        switch currentPlayerNum {
        case 0:
            player1CurrentPlay.removeAllChildren()
        case 1:
            player2CurrentPlay.removeAllChildren()
        default:
            player3CurrentPlay.removeAllChildren()
        }
    }
    
    
    func gameOver(winner: String) {
        gameOverMsg.text = winner + " wins!"
        gameOverMsg.isHidden = false
        startGameButton.isHidden = false
    }
    
    func showAlert(withTitle title: String, message: String) {
        alert.title = title
        alert.message = message
        alert.show()
    }
    
    public func disableAddAIButton() {
        addAIPlayerButton.isEnabled = false
    }
    
    public func enableStartGameButton() {
        startGameButton.isEnabled = true
    }
    
    @objc func timePassed() {
        countDown -= 1
        countDownLabel.text = String(countDown)
        if countDown < 0 {
            DouDiZhuGame.sharedInstace.timeOut()
            self.userMadeChoice()
        }
    }
    
    @objc func playButtonClicked() {
        DouDiZhuGame.sharedInstace.playButtonClicked()
    }
    
    @objc func hintButtonClicked() {
        DouDiZhuGame.sharedInstace.hintButtonClicked()
    }
    
    @objc func passButtonClicked() {
        DouDiZhuGame.sharedInstace.passButtonClicked()
    }
    
    @objc func addAIPlayer() {
        DouDiZhuGame.sharedInstace.addAIPlayer()
    }
    
    @objc func startGame() {
        
    }
    
    @objc func beLandlordButtonClicked() {
        self.userMadeChoice()
        self.hideBeLandlordActionButtons()
        //        self.game!.playerChooseToBeLandlord()
    }
    
    @objc func beFarmerButtonClicked() {
        self.userMadeChoice()
        self.hideBeLandlordActionButtons()
        //        self.game!.playerChooseToBeFarmer()
    }
}
