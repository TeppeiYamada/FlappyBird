//
//  GameScene.swift
//  FlappyBird
//
//  Created by 山田哲平 on 2017/01/24.
//  Copyright © 2017年 山田哲平. All rights reserved.
//

import SpriteKit
import AudioToolbox
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var item: SKSpriteNode!
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode: SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    let backGroundMusic = SKAudioNode(fileNamed: "02 Every Breaking Wave.m4a")
    
    
    

    override func didMove(to view: SKView){
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
    
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        
        self.addChild(backGroundMusic)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        
        setupScoreLabel()
        
        
    }
    
    
    
    func setupGround (){
    
    
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.nearest
        
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        
        stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            sprite.run(repeatScrollGround)
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            sprite.physicsBody?.isDynamic = false
            
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.isDynamic = false
            
            scrollNode.addChild(sprite)
        }
    
        let groundSprite = SKSpriteNode(texture: groundTexture)
        groundSprite.position = CGPoint(x:size.width / 2, y: groundTexture.size().height / 2)
        
        addChild(groundSprite)
    
    
    }
    
    
    func setupCloud(){
    
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.nearest
        
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20.0)
        
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        
        
        stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach{ i in
            let sprite = SKSpriteNode(texture: cloudTexture)
                sprite.zPosition = -100
        
        sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
        
        sprite.run(repeatScrollCloud)
        
        scrollNode.addChild(sprite)
        }
        
        
    
    }
    
    
    
    func setupWall(){
    
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.linear
        
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
        
        let removeWall = SKAction.removeFromParent()
        
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        let createWallAnimation = SKAction.run({
            
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0
            
            
            let center_y = self.frame.size.height / 2
            
            let random_y_range = self.frame.size.height / 4
            
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            
            let slit_length = self.frame.size.height / 6
            
            
            let under = SKSpriteNode(texture: wallTexture)
            
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            
            wall.addChild(under)
            
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            under.physicsBody?.isDynamic = false
            
            
            
            let upper = SKSpriteNode(texture: wallTexture)
            
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            
            
            let scoreNode = SKNode()
            
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            
            scoreNode.physicsBody?.isDynamic = false
            
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
            
        })
        
        
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    
    }
    
    
    func setupBird(){
    
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.linear
        
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.linear
        
        
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
    
        bird.run(flap)
        
        addChild(bird)
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if scrollNode.speed > 0 {
            
            bird.physicsBody?.velocity = CGVector.zero
            
            
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory
        {
            print("itemScoreUp")
            itemScore += 1
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            
            let removeItem = contact.bodyA.node?.removeFromParent()
            
            let soundIdRing:SystemSoundID = 1000
            AudioServicesPlaySystemSound(soundIdRing)
            
        
        
        }
        
        
        else {
            
            print("GameOver")
            
            let stopAction = SKAction.stop()
            backGroundMusic.run(stopAction)

            
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        
        itemScore = 0
        itemScoreLabelNode.text = String("Item Score:\(itemScore)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
        let playAction = SKAction.play()
        backGroundMusic.run(playAction)

        
        
    }
    
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100 
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
        
    }
    
    func setupItem(){
    
    
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = SKTextureFilteringMode.linear
        
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
    
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
    
        let removeItem = SKAction.removeFromParent()
    
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        
    
        let createItemAnimation = SKAction.run({
        
        let item = SKNode()
            
        item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0.0)
        item.zPosition = -50.0
            
            
            // アイテム作成
            let itemApple = SKSpriteNode(texture: itemTexture)
            
            let center_y = self.frame.size.height / 1.5
            
            let random_y_range = self.frame.size.height / 4
            
            let item_lowest_y = UInt32( center_y - itemTexture.size().height / 2 -  random_y_range / 2)
            
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            
            let item_y = CGFloat(item_lowest_y + random_y)
            
            
            itemApple.position = CGPoint(x: 0.0, y: item_y)
            
            itemApple.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: itemApple.size.width, height: itemApple.size.height))
            itemApple.physicsBody?.categoryBitMask = self.itemCategory
            
            itemApple.physicsBody?.isDynamic = false
            
            itemApple.physicsBody?.contactTestBitMask = self.birdCategory
            
            itemApple.xScale = 0.20
            itemApple.yScale = 0.20
            
            item.addChild(itemApple)
            
            item.run(itemAnimation)
            
            self.wallNode.addChild(item)
        
    })

        let waitAnimation = SKAction.wait(forDuration: 2)
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    
    }
       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
