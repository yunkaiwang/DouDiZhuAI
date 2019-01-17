//
//  CardUIButton.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-14.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import SpriteKit

class CardButtonNode: FTButtonNode {
    private var isClicked: Bool = false
    
    init(normalTexture defaultTexture: SKTexture!) {
        super.init(normalTexture: defaultTexture, selectedTexture: defaultTexture, disabledTexture: nil)
        self.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(CardButtonNode.CardClicked))
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func CardClicked() {
        if !isClicked {
            self.position.y += CGFloat(20)
            isClicked = true
        } else {
            self.position.y -= CGFloat(20)
            isClicked = false
        }
    }
}

