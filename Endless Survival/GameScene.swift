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
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if innerCircle.contains(touchLocation) {
            isJoystickActive = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isJoystickActive, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Calculate distance and angle from outer circle's center
        let dx = touchLocation.x - outerCircle.position.x
        let dy = touchLocation.y - outerCircle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        // Limit inner circle's movement to the outer circle's bounds
        if distance <= joystickRadius {
            innerCircle.position = touchLocation
        } else {
            innerCircle.position = CGPoint(x: outerCircle.position.x + cos(angle) * joystickRadius,
                                           y: outerCircle.position.y + sin(angle) * joystickRadius)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isJoystickActive = false
        // Reset inner circle position to outer circle's center
        innerCircle.position = outerCircle.position
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // Calculate distance between the inner circle and the outer circle's center
        let dx = innerCircle.position.x - outerCircle.position.x
        let dy = innerCircle.position.y - outerCircle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Calculate the maximum distance (radius of the outer circle)
        let maxDistance = joystickRadius
        
        // Calculate the distance ratio
        let distanceRatio = distance / maxDistance
        
        // Calculate the speed multiplier
        let speedMultiplier = distanceRatio
        
        // Calculate movement vector
        let angle = atan2(dy, dx)
        let movementX = cos(angle) * joystickSpeed * speedMultiplier
        let movementY = sin(angle) * joystickSpeed * speedMultiplier
        
        // Move the player
        if(isJoystickActive && dx != 0.0 && dy != 0.0){
            player.position.x += movementX
            player.position.y += movementY
        }
    }
}


