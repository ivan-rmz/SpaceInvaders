//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Alumno on 25/11/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //Initialize player
    let player = SKSpriteNode(imageNamed: "playerShip")
    // Initialize shot sound action
    let bulletSound = SKAction.playSoundFileNamed("bulletShot.wav", waitForCompletion: false)
    //Initialize game area
    let gameArea : CGRect
    
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    override init(size : CGSize) {
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        print("Min X: ", gameArea.minX)
        print("Max X: ", gameArea.maxX)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //Initialize and add background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        //Add player
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        player.zPosition = 2
        self.addChild(player)
        
        startNewLevel()
    }
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy(){
        //Initialize x coordinates to start and end
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        //Establish start and end points
        let startPoint = CGPoint(x: randomXStart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let angle = atan2(dy, dx)
        enemy.zRotation = angle
        
    }
    
    func startNewLevel(){
        let spawn = SKAction.run(spawnEnemy)
        let waitSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, waitSpawn])
        let spawn4Ever = SKAction.repeatForever(spawnSequence)
        self.run(spawn4Ever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
        //spawnEnemy()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPOT = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPOT.x
            
            player.position.x  += amountDragged
            
            //Too far right
            if player.position.x > (gameArea.maxX){ //- player.size.width/2
                
                player.position.x = gameArea.maxX - (player.size.width*0.01)
                print("Max derecha: ", player.position.x)
            }
            //Too far left
            if player.position.x < (gameArea.minX){ //+ player.size.width/2
                player.position.x = gameArea.minX + (player.size.width*0.01)
                print("Max izquierda: ", player.position.x)
            }
            
        }
    }
}
