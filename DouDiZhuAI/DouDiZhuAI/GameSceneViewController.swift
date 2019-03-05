//
//  GameSceneViewController.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import UIKit
import SpriteKit

class GameSceneViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: UIScreen.main.bounds.size)
        let skView = self.view as! SKView
        GameScene.gameController = self
        scene.scaleMode = .aspectFill
        Game.gameScene = scene
        skView.presentScene(scene)
    }
}
