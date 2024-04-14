//
//  GameScene.swift
//  Endless Survival
//
//  Created by justin.wagoner on 3/23/24.
//

import SpriteKit
import GameplayKit

func mp<T>(_ name: String, _ value: T) {
    print("\(name): \(value)")
}


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
    private var joystickSpeed: CGFloat = 0.2 // Adjust as needed

    private var cameraNode = SKCameraNode()

    
    override func sceneDidLoad() {
        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: self.size)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)

        // Set up the camera
        self.camera = cameraNode;
        cameraNode.position = background.position
        addChild(cameraNode)

        // Create player as child of camera
        player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = background.position
        player.zPosition = 3;
        self.addChild(player)

        // Calculate the position of the outer circle in screen coordinates
        let outerCircleScreenPosition = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.2)

        // Convert screen coordinates to world coordinates
        let outerCircleWorldPosition = self.convert(outerCircleScreenPosition, to: cameraNode)

        // Create outer circle (grey) as child of camera
        outerCircle = SKShapeNode(circleOfRadius: joystickRadius)
        outerCircle.position = outerCircleWorldPosition
        outerCircle.fillColor = .gray
        outerCircle.alpha = 0.5
        outerCircle.zPosition = 1
        cameraNode.addChild(outerCircle)

        // Create inner circle (black) as child of outer circle
        innerCircle = SKShapeNode(circleOfRadius: 20)
        innerCircle.position = CGPoint.zero
        innerCircle.fillColor = .black
        innerCircle.zPosition = 2
        outerCircle.addChild(innerCircle)
    }

    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: outerCircle) // Convert to outer circle's coordinate system
        
        if innerCircle.contains(touchLocation) {
            isJoystickActive = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isJoystickActive, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self) // Convert to scene's coordinate system
        let touchLocationInOuterCircle = convert(touchLocation, to: outerCircle) // Convert to outer circle's coordinate system

        // Calculate distance and angle from outer circle's center
        let dx = touchLocationInOuterCircle.x
        let dy = touchLocationInOuterCircle.y
        if(touchLocationInOuterCircle != CGPoint.zero){
            //print(touchLocationInOuterCircle)
        }
        let distance = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
                
        // Limit inner circle's movement to the outer circle's bounds
        if distance <= joystickRadius {
            innerCircle.position = touchLocationInOuterCircle
        } else {
            innerCircle.position = CGPoint(x: cos(angle) * joystickRadius,
                                           y: sin(angle) * joystickRadius)
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isJoystickActive = false
        // Reset inner circle position to outer circle's center
        innerCircle.position = CGPoint.zero
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // Calculate movement vector
        let dx = innerCircle.position.x
        let dy = innerCircle.position.y
        
        // Calculate movement direction
        let angle = atan2(dy, dx)
        
        // Calculate the speed multiplier
        let speedMultiplier = joystickSpeed
        
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
    }
}


