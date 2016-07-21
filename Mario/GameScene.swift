//
//  GameScene.swift
//  Mario
//
//  Created by David Gunawan on 7/21/16.
//  Copyright (c) 2016 Davidgun. All rights reserved.
//

import SpriteKit
import CoreGraphics

struct CollisionNames {
    static let Mario : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Coin : UInt32 = 0x1 << 4
    static let Flag : UInt32 = 0x1 << 8
    static let Fire : UInt32 = 0x1 << 16
    static let Fireball : UInt32 = 0x1 << 20
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Map = JSTileMap()
    
    var Mario = SKSpriteNode()
    
    var movingLeft = Bool()
    var movingRight = Bool()
    
    var cam = SKCameraNode()
    
    var bankValue = Int()
    
    var flag = SKSpriteNode()
    
    var levelNumber = Int()
    
    var coinLbl = SKLabelNode()
    
    var time = Int()
    var bulletTime = Int()
    var fireballTime = Int()
    
    func setupScene(scene: String) {
        
        for node in self.children {
            node.removeFromParent()
        }
        
        let userDefaults = NSUserDefaults()
        
        if userDefaults.integerForKey("bank") != 0 {
            
            bankValue = userDefaults.integerForKey("bank")
            
        } else {
            
            bankValue = 0
            
        }
        
        coinLbl.text = "Coins : \(bankValue)"
        coinLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3)
        self.addChild(coinLbl)
        
        
        Map = JSTileMap(named: scene)
        Map.position = CGPoint(x: 0, y: 0)
        self.addChild(Map)
        
        let gestureUp = UISwipeGestureRecognizer(target: self, action: Selector("jump"))
        gestureUp.direction = UISwipeGestureRecognizerDirection.Up
        view!.addGestureRecognizer(gestureUp)
        
        self.physicsWorld.contactDelegate = self
        
        self.camera = cam
        self.addChild(cam)
        cam.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2)
        
        Mario = SKSpriteNode(imageNamed: "Mario1")
        Mario.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        Mario.size = CGSizeMake(30, 45)
        
        Mario.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: Mario.size.width, height: Mario.size.height))
        Mario.physicsBody?.categoryBitMask = CollisionNames.Mario
        Mario.physicsBody?.collisionBitMask = CollisionNames.Ground | CollisionNames.Coin
        Mario.physicsBody?.contactTestBitMask = CollisionNames.Ground | CollisionNames.Coin
        Mario.physicsBody?.allowsRotation = false
        Mario.physicsBody?.affectedByGravity = true
        
        self.addChild(Mario)
        
        
        let groundGroup : TMXObjectGroup = self.Map.groupNamed("GroundObjects")
        let coinGroup : TMXObjectGroup = self.Map.groupNamed("Coins")
        let flagGroup : TMXObjectGroup = self.Map.groupNamed("EndObject")
        let powerUpGroup : TMXObjectGroup = self.Map.groupNamed("PowerUps")
        
        let flagObject = flagGroup.objectNamed("Flag") as NSDictionary
        
        let width = flagObject.objectForKey("width") as! String
        let height = flagObject.objectForKey("height") as! String
        
        let flagSize = CGSize(width: Int(width)!, height: Int(height)!)
        
        flag = SKSpriteNode(imageNamed: "Flag", normalMapped:  false)
        flag.color = UIColor.clearColor()
        flag.size = flagSize
        
        let x = flagObject.objectForKey("x") as! Int
        let y = flagObject.objectForKey("y") as! Int
        
        flag.position = CGPoint(x: x + Int(flagGroup.positionOffset.x) + Int(width)! / 2 , y: y + Int(flagGroup.positionOffset.y) + Int(height)! / 2)
        
        flag.physicsBody = SKPhysicsBody(rectangleOfSize: flagSize)
        flag.physicsBody?.affectedByGravity = false
        flag.physicsBody?.categoryBitMask = CollisionNames.Flag
        flag.physicsBody?.collisionBitMask = CollisionNames.Mario
        flag.physicsBody?.contactTestBitMask = CollisionNames.Mario
        
        self.addChild(flag)
        
        for i in 0..<powerUpGroup.objects.count{
            let powerUpObject = powerUpGroup.objectNamed("Fire") as NSDictionary
            
            let width = powerUpObject.objectForKey("width") as! String
            let height = powerUpObject.objectForKey("height") as! String
            
            let powerUpize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let powerUpSprite = SKSpriteNode(imageNamed: "Fireball", normalMapped:  false)
            powerUpSprite.color = UIColor.clearColor()
            powerUpSprite.size = powerUpize
            
            let x = powerUpObject.objectForKey("x") as! Int
            let y = powerUpObject.objectForKey("y") as! Int
            
            powerUpSprite.position = CGPoint(x: x + Int(powerUpGroup.positionOffset.x) + Int(width)! / 2 , y: y + Int(powerUpGroup.positionOffset.y) + Int(height)! / 2)
            
            powerUpSprite.physicsBody = SKPhysicsBody(rectangleOfSize: powerUpize)
            powerUpSprite.physicsBody?.affectedByGravity = false
            powerUpSprite.physicsBody?.categoryBitMask = CollisionNames.Fire
            powerUpSprite.physicsBody?.collisionBitMask = CollisionNames.Mario
            powerUpSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            self.addChild(powerUpSprite)
        }
        
        for i in 0..<coinGroup.objects.count{
            let coinObject = coinGroup.objects.objectAtIndex(i) as! NSDictionary
            
            let width = coinObject.objectForKey("width") as! String
            let height = coinObject.objectForKey("height") as! String
            
            let coinSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let coinSprite = SKSpriteNode(imageNamed: "Coin")
            coinSprite.size = coinSize
            
            let x = coinObject.objectForKey("x") as! Int
            let y = coinObject.objectForKey("y") as! Int
            
            coinSprite.position = CGPoint(x: x + Int(coinGroup.positionOffset.x) + Int(width)! / 2 , y: y + Int(coinGroup.positionOffset.y) + Int(height)! / 2)
            
            coinSprite.physicsBody = SKPhysicsBody(rectangleOfSize: coinSize)
            coinSprite.physicsBody?.affectedByGravity = false
            coinSprite.physicsBody?.categoryBitMask = CollisionNames.Coin
            coinSprite.physicsBody?.collisionBitMask = CollisionNames.Mario
            coinSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            self.addChild(coinSprite)
        }
        
        for i in 0..<groundGroup.objects.count{
            let groundObject = groundGroup.objects.objectAtIndex(i) as! NSDictionary
            let width = groundObject.objectForKey("width") as! String
            let height = groundObject.objectForKey("height") as! String
            
            let wallSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            let groundSprite = SKSpriteNode(color: UIColor.clearColor(), size: wallSize)
            
            let x = groundObject.objectForKey("x") as! Int
            let y = groundObject.objectForKey("y") as! Int
            
            groundSprite.position = CGPoint(x: x + Int(groundGroup.positionOffset.x) + Int(width)! / 2 , y: y + Int(groundGroup.positionOffset.y) + Int(height)! / 2)
            
            groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: wallSize)
            groundSprite.physicsBody?.categoryBitMask = CollisionNames.Ground
            groundSprite.physicsBody?.collisionBitMask = CollisionNames.Mario
            groundSprite.physicsBody?.contactTestBitMask = CollisionNames.Mario
            
            groundSprite.physicsBody?.affectedByGravity = false
            groundSprite.physicsBody?.dynamic = false
            
            self.addChild(groundSprite)
            
        }

        
    }
    
    override func didMoveToView(view: SKView) {
        
        let userDefaults = NSUserDefaults()
        
        if userDefaults.integerForKey("levelNumber") != 0 {
           // let levelNumber = userDefaults.integerForKey("levelNumber") as Int!
            levelNumber = 1
            let currentLevel = "level\(levelNumber).tmx"
            setupScene(currentLevel)
        }
        else {
            setupScene("level1.tmx")
            levelNumber = 1
        }
        
        
    }
    
    func jump(){
        
        self.Mario.physicsBody?.applyImpulse(CGVectorMake(0 , 20))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Mario && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Coin {
            
            bodyB.node?.removeFromParent()
            bankValue += 1
            coinLbl.text = "Coins : \(bankValue)"
            
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Coin && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Mario {
            
            bodyA.node?.removeFromParent()
            bankValue += 1
            coinLbl.text = "Coins : \(bankValue)"
            
        }
        
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Mario && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Flag {
            levelNumber += 1
            let userDefaults = NSUserDefaults()
            userDefaults.setInteger(levelNumber, forKey: "levelNumber")
            let currentLevel = "level\(levelNumber).tmx"
            userDefaults.setObject(bankValue, forKey: "bank")
            setupScene(currentLevel)
            
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Flag && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Mario {
            levelNumber += 1
            let userDefaults = NSUserDefaults()
            userDefaults.setInteger(levelNumber, forKey: "levelNumber")
            let currentLevel = "level\(levelNumber).tmx"
            userDefaults.setObject(bankValue, forKey: "bank")
            setupScene(currentLevel)
            
        }
        
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Mario && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Fire {
            
            bulletTime = time + 600
            bodyB.node?.removeFromParent()
            shootFireball()
            
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Coin && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Fire {
            
            bulletTime = time + 600
            bodyA.node?.removeFromParent()
            shootFireball()
            
        }
        
    }
    
    func shootFireball(){
        
        fireballTime = time + 20
        
        let fireball = SKSpriteNode(imageNamed: "Fireball")
        fireball.size = CGSize(width: 15, height: 15)
        fireball.position = Mario.position
        
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width / 2)
        fireball.physicsBody?.affectedByGravity = true
        fireball.physicsBody?.friction = 0
        fireball.physicsBody?.restitution = 0.8
        
        fireball.physicsBody?.categoryBitMask = CollisionNames.Fireball
        fireball.physicsBody?.collisionBitMask = CollisionNames.Ground
        fireball.physicsBody?.contactTestBitMask = CollisionNames.Ground
        
        let actionSequence = SKAction.sequence([SKAction.waitForDuration(2), SKAction.fadeOutWithDuration(0.5)])
        
        fireball.runAction(actionSequence)
        
        self.addChild(fireball)
        
        if Mario.xScale == -1{
            
            fireball.physicsBody?.applyImpulse(CGVectorMake(-2, 2))
            
        } else {
            
            fireball.physicsBody?.applyImpulse(CGVectorMake(2, 2))
            
        }
        
        
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
      
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if location.x >= Mario.position.x {
                movingLeft = true
                
                var textureArray = [SKTexture]()
                textureArray = [SKTexture(imageNamed : "Mario2"), SKTexture(imageNamed : "Mario3")]
                Mario.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.2)))
                Mario.xScale = 1
                
            }
            else if location.x <= Mario.position.x {
                movingRight = true
                
                var textureArray = [SKTexture]()
                textureArray = [SKTexture(imageNamed : "Mario2"), SKTexture(imageNamed : "Mario3")]
                Mario.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.2)))
                Mario.xScale = -1
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if movingLeft == true {
            
            movingLeft = false
            Mario.removeAllActions()
            Mario.texture = SKTexture(imageNamed: "Mario1")
            
        }
        
        else if movingRight == true {
            
            movingRight = false
            Mario.removeAllActions()
            Mario.texture = SKTexture(imageNamed: "Mario1")
            
        }
        
        Mario.physicsBody?.velocity = CGVectorMake(0, 0)
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        time += 1
        
        if bulletTime + 600 >= time{
            
            if fireballTime == time{
                
                shootFireball()
            }
            
        } else {
            
            fireballTime = time
            
        }
        
        if movingLeft == true {
            if Mario.physicsBody?.velocity.dx <= 100 {
                Mario.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
            }
            else {
                
            }
        }
        else if movingRight == true {
            if Mario.physicsBody?.velocity.dx >= -100 {
                Mario.physicsBody?.applyForce(CGVector(dx: -100, dy: 0))
            }
            else {
                
            }
        }
        if Mario.position.x >= self.frame.width / 2 {
            cam.position.x = Mario.position.x
            coinLbl.position.x = Mario.position.x
        }
        
    }
}
