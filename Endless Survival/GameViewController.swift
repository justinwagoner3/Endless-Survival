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
           
        if let view = self.view as! SKView? {

            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 2048, height: 1536))

            // Set the scale mode to scale to fit the window
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
