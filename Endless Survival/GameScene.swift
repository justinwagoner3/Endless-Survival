//
//  GameScene.swift
//  Endless Survival
//
//  Created by justin.wagoner on 3/23/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // Define joystick nodes
    private var outerCircle: SKShapeNode!
    private var innerCircle: SKShapeNode!
    
    // Define player node
    private var player: SKSpriteNode!
    
    // Define joystick properties
    private var joystickRadius: CGFloat = 75.0 // Adjust as needed
    private var isJoystickActive = false
    private var joystickSpeed: CGFloat = 5.0 // Adjust as needed

    
    override func sceneDidLoad() {
            
        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: self.size)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        // Create outer circle (grey)
        outerCircle = SKShapeNode(circleOfRadius: joystickRadius)
        outerCircle.position = CGPoint(x: self.size.width*0.1, y: self.size.height * 0.2)
        outerCircle.fillColor = .gray
        outerCircle.alpha = 0.5
        outerCircle.zPosition = 1
        addChild(outerCircle)
        
        // Create inner circle (black)
        innerCircle = SKShapeNode(circleOfRadius: 20) // Adjust size as needed
        innerCircle.position = outerCircle.position
        innerCircle.fillColor = .black
        innerCircle.zPosition = 2
        addChild(innerCircle)
        
        // Create player
        player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50)) // Adjust size and color as needed
        player.position = CGPoint(x: size.width / 2, y: size.height / 2) // Adjust starting position as needed
        player.zPosition = 3;
        addChild(player)

        print("x: \(self.size.width)")
        print("y: \(self.size.height)")
        print("\(outerCircle.position)")
        print("\(player.position)")

        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
