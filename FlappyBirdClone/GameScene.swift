//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Arkadiy Grigoryanc on 27.01.17.
//  Copyright © 2017 Arkadiy Grigoryanc. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    
    var moveAnRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    
    let scoreLabel = SKLabelNode()
    
    var died = Bool()
    
    var restartButton = SKSpriteNode()
    
    let widthWall: CGFloat = 100.0
    
    override func didMove(to view: SKView) {
        
        createScene()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            
            gameStarted = true
            
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            run(spawnDelayForever)
            
            let distance = CGFloat(frame.width + widthWall / 2)
            
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAnRemove = SKAction.sequence([movePipes, removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            
        } else {
            
            if !died {
                
                ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
                
            } else {
                
                for touch in touches {
                    
                    let location = touch.location(in: self)
                    
                    if restartButton.contains(location) {
                        restartScene()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if gameStarted {
            
            if !died {
                
                enumerateChildNodes(withName: "background", using: { (node, error) in
                    
                    let background = node as! SKSpriteNode
                    background.position = CGPoint(x: background.position.x - 2,
                                                  y: background.position.y)
                    
                    if background.position.x <= -background.size.width {
                        
                        background.position = CGPoint(x: background.position.x + background.size.width * 2,
                                                      y: background.position.y)
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            score += 10
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        } else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.score {
            
            score += 10
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        } else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.wall ||
            firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            //self.scene?.speed = 0
            
            enumerateChildNodes(withName: "wallPair", using: { (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            })
            
            if !died {
                died = true
                createRestatrButton()
            }
            
        } else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.ground ||
            firstBody.categoryBitMask == PhysicsCategory.ground && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            //self.scene?.speed = 0
            
            enumerateChildNodes(withName: "wallPair", using: { (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            })
            
            if !died {
                died = true
                createRestatrButton()
            }
        }
        
    }
    
    // MARK: - Methods
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size = CGSize(width: widthWall / 2,
                                height: widthWall / 2)
        scoreNode.position = CGPoint(x: frame.width,
                                     y: frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: frame.width,
                                   y: frame.height / 2 + 380)
        bottomWall.position = CGPoint(x: frame.width,
                                      y: frame.height / 2 - 380)
        
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        topWall.zRotation = CGFloat(M_PI)
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -150, max: 150)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAnRemove)
        
        addChild(wallPair)
        
    }
    
    func createRestatrButton() {
        
        //restartButton = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 200, height: 100))
        restartButton = SKSpriteNode(imageNamed: "RestartBtn")
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        restartButton.setScale(0)
        restartButton.zPosition = 99
        addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    func restartScene() {
        
        removeAllChildren()
        removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
        
    }
    
    func createScene() {
        
        physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPoint()
            background.position = CGPoint(x: CGFloat(i) * frame.width, y: 0)
            background.name = "background"
            background.size = (view?.bounds.size)!
            addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2 + frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 80
        scoreLabel.zPosition = 99
        addChild(scoreLabel)
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: frame.width / 2, y: 0 + ground.frame.height / 2)
        ground.zPosition = 3
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: frame.width / 2 - ghost.frame.width, y: frame.height / 2)
        ghost.zPosition = 2
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height / 2)
        ghost.physicsBody?.categoryBitMask = PhysicsCategory.ghost
        ghost.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        ghost.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.isDynamic = true
        addChild(ghost)
        
    }
}












