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
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
