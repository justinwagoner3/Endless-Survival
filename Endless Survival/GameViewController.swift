//
//  GameViewController.swift
//  Endless Survival
//
//  Created by justin.wagoner on 3/23/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            
            // Get the screen size
            let screenSize = UIScreen.main.bounds.size
            
            // Determine the aspect ratio
            let aspectRatio = screenSize.width / screenSize.height
            
            // Define the base size for your scene (you can adjust this as needed)
            let baseWidth: CGFloat = 2048.0
            let baseHeight: CGFloat = 1536.0
            
            // Calculate the scaled size based on the aspect ratio
            var sceneSize: CGSize
            if aspectRatio > 1.0 {
                // Landscape orientation
                sceneSize = CGSize(width: baseWidth, height: baseWidth / aspectRatio)
            } else {
                // Portrait orientation
                sceneSize = CGSize(width: baseHeight * aspectRatio, height: baseHeight)
            }
            
            // Load the SKScene with the calculated size
            let scene = GameScene(size: sceneSize)
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
