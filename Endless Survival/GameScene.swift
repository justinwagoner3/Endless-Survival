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
    private var joystickOuter: SKNode!
    private var joystickInner: SKNode!
    
    // Define player node
    private var player: SKSpriteNode!
    
    // Define joystick properties
    private var joystickRadius: CGFloat = 0.0
    private var isJoystickActive = false
    private var joystickSpeed: CGFloat = 5.0 // Adjust as needed

    
    override func sceneDidLoad() {
        createBackground()
        createPlayer()
    }

    func createBackground() {
        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: self.size)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        self.addChild(background)
    }
    
    func createPlayer() {
        // Create player
        player = SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 25)) // Adjust size and color as needed
        player.position = CGPoint(x: 0, y: 0) // Adjust starting position as needed
        player.zPosition = 3;
        addChild(player)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Retrieve joystick elements from the SKS file
        joystickOuter = childNode(withName: "joystickOuter")
        joystickInner = joystickOuter.childNode(withName: "joystickInner")
        
        print(joystickOuter.position)
        print(joystickInner.position)

        
    }

    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Convert touch location to the coordinate system of the joystickOuter node
        let touchLocation = touch.location(in: joystickOuter)
        
        // Check if the touch is within the bounds of the joystickInner node
        if joystickInner.contains(touchLocation) {
            isJoystickActive = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
    }
}


