//
//  CardUIButton.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-14.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import SpriteKit

class CardButtonNode: FTButtonNode {
    private var card: Card
    private var isClicked: Bool
    private var game: DouDiZhuGame
    
    init(normalTexture defaultTexture: SKTexture!, card: Card, game: DouDiZhuGame) {
        self.card = card
        self.game = game
        self.isClicked = false
        super.init(normalTexture: defaultTexture, selectedTexture: defaultTexture, disabledTexture: nil)
        self.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(CardButtonNode.CardClicked))
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func CardClicked() {
        self.game.cardIsClicked(card: self.card)
        if !isClicked {
            self.position.y += CGFloat(20)
            isClicked = true
        } else {
            self.position.y -= CGFloat(20)
            isClicked = false
        }
    }
    
    func getIdentifier()->String {
        return self.card.getIdentifier()
    }
}

