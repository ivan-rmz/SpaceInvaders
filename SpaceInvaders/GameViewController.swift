//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created by Alumno on 25/11/21.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()

    override func viewDidLoad() {

        super.viewDidLoad()
        let filePath = Bundle.main.path(forResource: "Space Invaders Song", ofType: "mp3")
        let audioURL = URL(fileURLWithPath: filePath!)
        
        do{ backingAudio = try AVAudioPlayer(contentsOf: audioURL) }
        catch{
            return print("Cannot play audio")
        }
        
        backingAudio.numberOfLoops = -1
        backingAudio.play()

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }

    }

    override var shouldAutorotate: Bool {
        return true
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
