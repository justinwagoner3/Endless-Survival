//
//  GameScene.swift
//  Endless Survival
//
//  Created by justin.wagoner on 3/23/24.
//

import SpriteKit
import GameplayKit

// print func for logging
func mp<T>(_ name: String, _ value: T) {
    print("\(name): \(value)")
}


class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // Define joystick nodes
    private var joystickOuterCircle: SKShapeNode!
    private var joystickInnerCircle: SKShapeNode!
    
    // Define player node
    private var player: SKSpriteNode!
    
    // Define joystick properties
    private var joystickRadius: CGFloat = 75.0 // Adjust as needed
    private var isJoystickActive = false
    private var speedMultiplier: CGFloat = 1 // Adjust as needed

    private var cameraNode = SKCameraNode()

    
    override func sceneDidLoad() {
        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: self.size)
        //let background = SKSpriteNode(imageNamed:"background_generic")
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)

        // Set up the camera
        self.camera = cameraNode;
        cameraNode.position = background.position
        addChild(cameraNode)

        // Create player
        player = SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 25))
        player.position = background.position
        player.zPosition = 3;
        self.addChild(player)

        // Calculate the position of the outer circle in screen coordinates
        let joystickOuterCircleScreenPosition = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.2)

        // Convert screen coordinates to world coordinates
        let joystickOuterCircleWorldPosition = self.convert(joystickOuterCircleScreenPosition, to: cameraNode)

        // Create outer circle (grey) as child of camera
        joystickOuterCircle = SKShapeNode(circleOfRadius: joystickRadius)
        joystickOuterCircle.position = joystickOuterCircleWorldPosition
        joystickOuterCircle.fillColor = .gray
        joystickOuterCircle.alpha = 0.5
        joystickOuterCircle.zPosition = 1
        cameraNode.addChild(joystickOuterCircle)

        // Create inner circle (black) as child of outer circle
        joystickInnerCircle = SKShapeNode(circleOfRadius: 20) // Adjust as needed
        joystickInnerCircle.position = CGPoint.zero
        joystickInnerCircle.fillColor = .black
        joystickInnerCircle.zPosition = 2
        joystickOuterCircle.addChild(joystickInnerCircle)
    }

    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: joystickOuterCircle) // Convert to outer circle's coordinate system
        
        if joystickInnerCircle.contains(touchLocation) {
            isJoystickActive = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isJoystickActive, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self) // Convert to scene's coordinate system
        let touchLocationInjoystickOuterCircle = convert(touchLocation, to: joystickOuterCircle) // Convert to outer circle's coordinate system

        // Calculate distance and angle from outer circle's center
        let dx = touchLocationInjoystickOuterCircle.x
        let dy = touchLocationInjoystickOuterCircle.y
        let distance = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
                
        // Limit inner circle's movement to the outer circle's bounds
        if distance <= joystickRadius {
            joystickInnerCircle.position = touchLocationInjoystickOuterCircle
        } else {
            joystickInnerCircle.position = CGPoint(x: cos(angle) * joystickRadius,
                                           y: sin(angle) * joystickRadius)
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isJoystickActive = false
        // Reset inner circle position to outer circle's center
        joystickInnerCircle.position = CGPoint.zero
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // Calculate movement vector
        let dx = joystickInnerCircle.position.x
        let dy = joystickInnerCircle.position.y
        
        // Calculate movement direction
        let angle = atan2(dy, dx)
                
        // Calculate movement vector
        let movementX = cos(angle) * speedMultiplier
        let movementY = sin(angle) * speedMultiplier
        
        // Move the player
        if isJoystickActive {
            player.position.x += movementX
            player.position.y += movementY
        }
        
        // Have camera follow playr
        cameraNode.position = player.position
        
        //mp("player.position",player.position)
    }
}


