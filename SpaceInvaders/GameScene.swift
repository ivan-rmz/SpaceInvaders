//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Alumno on 25/11/21.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Initialize player
    let player = SKSpriteNode(imageNamed: "playerShip")
    // Initialize shot sound action
    let bulletSound = SKAction.playSoundFileNamed("bulletShot.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("shortExplosion.wav", waitForCompletion: false)
    //Initialize game area
    let gameArea : CGRect
    let tapStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    var gameLevel = 0
    var lives = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    enum gameState{
        case preGame //before the start of the game
        case inGame //during the game
        case postGame //end of the game
    }
    var currentGameState = gameState.preGame
    
    struct PhysicsCateories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    
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
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        //Initialize and add background
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        //Add player
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCateories.Player
        player.physicsBody!.collisionBitMask = PhysicsCateories.None
        player.physicsBody!.contactTestBitMask = PhysicsCateories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Puntos: 0"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 70
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9 + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Vidas: 3"
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 70
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.9 + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreen = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreen)
        livesLabel.run(moveOnToScreen)
        
        
        tapStartLabel.text = "Toca para Iniciar"
        tapStartLabel.fontSize = 100
        tapStartLabel.fontColor = SKColor.white
        tapStartLabel.zPosition = 1
        tapStartLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        tapStartLabel.alpha = 0
        self.addChild(tapStartLabel)
        
        let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 1)
        tapStartLabel.run(fadeInAction)
        
        
        
        //startNewLevel()
    }
    var lastUpdtTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSec: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdtTime == 0{
            lastUpdtTime = currentTime
        }else{
            deltaFrameTime = currentTime - lastUpdtTime
            lastUpdtTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSec * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") { background, stop in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
                
            }
        }
        
    }
    
    func startGame(){
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapStartLabel.run(deleteSequence)
        
        let moveShipScreen = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipScreen, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 15 || gameScore == 25 || gameScore == 35 {
            startNewLevel()
        }
        
    }
    
    func loseLive(){
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
        
        let scaleUp = SKAction.scale(by: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let changeColor = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0)
        let returnColor = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0)
        let scaleSequence = SKAction.sequence([changeColor, scaleUp, scaleDown, returnColor])
        livesLabel.run(scaleSequence)
        
        if lives == 0 {
            gameOver()
        }
    }
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCateories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCateories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCateories.Enemy
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
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCateories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCateories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCateories.Bullet | PhysicsCateories.Player //
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseLife = 	SKAction.run(loseLive)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLife])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let angle = atan2(dy, dx)
        enemy.zRotation = angle
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCateories.Player && body2.categoryBitMask == PhysicsCateories.Enemy{
            //if the player has hit the enemy
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            gameOver()
        }
        if body1.categoryBitMask == PhysicsCateories.Bullet && body2.categoryBitMask == PhysicsCateories.Enemy{
            //if the bullet has hit the enemy
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return //if the enemy is off the top of the screen, 'return'. This will stop running this code here, therefore doing nothing unless we hit the enemy when it's on the screen. As we are already checking that body2.node isn't nothing, we can safely unwrap (with '!)' this here.
                }
                else{
                    spawnExplosion(spawnPosition: body2.node!.position)
                    addScore()
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    func startNewLevel(){
        gameLevel += 1
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        switch gameLevel{
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("no level info")
        }
        
        
        let spawn = SKAction.run(spawnEnemy)
        let waitSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitSpawn, spawn])
        let spawn4Ever = SKAction.repeatForever(spawnSequence)
        self.run(spawn4Ever, withKey: "spawningEnemies")
    }
    
    func gameOver(){
        
        currentGameState = gameState.postGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") { bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy") { enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitChangeScene, changeSceneAction])
        self.run(changeSceneAction)
        
    }
    
    func changeScene(){
        let sceneToMove = GameOverScene(size: self.size)
        sceneToMove.scaleMode = self.scaleMode
        let isTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMove, transition: isTransition)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        
        if currentGameState == gameState.inGame{
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPOT = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPOT.x
            
            if currentGameState == gameState.inGame {
                player.position.x  += amountDragged
            }
            
            
            //Too far rightbbbbb
            if player.position.x > (gameArea.maxX){ //- player.size.width/2
                
                player.position.x = gameArea.maxX - (player.size.width*0.01)
            }
            //Too far left
            if player.position.x < (gameArea.minX){ //+ player.size.width/2
                player.position.x = gameArea.minX + (player.size.width*0.01)
            }
            
        }
    }
}
