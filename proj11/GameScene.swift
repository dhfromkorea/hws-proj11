import GameplayKit
import SpriteKit

// TODO: add sound, do https://www.hackingwithswift.com/read/11/8/wrap-up
class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            editLabel.text = editingMode ? "Done" : "Edit"
        }
    }
    
    override func didMove(to view: SKView) {
        setBackground(at: CGPoint(x: 512, y: 384))
        
        for i in 0...4 {
            makeBouncer(at: CGPoint(x: i * (Int(frame.width) / 4), y: 0))
        }
        
        var isGood = true
        for i in 0...3 {
            makeSlot(at: CGPoint(x: 128 + i * 256, y: 0), isGood: isGood)
            isGood = !isGood
        }
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        setScoreLabel(at: CGPoint(x : 980, y: 700))
        setEditLabel(at: CGPoint(x : 80, y: 700))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    // create an obstacle
                    makeBox(at: location)
                } else {
                    makeBall(at: location)
                }
                
            }
            
        }
    }
    
    // MARK: CRUD methods for creating elements in the game
    
    func setBackground(at position: CGPoint) {
        let background = SKSpriteNode(imageNamed: "background.jpg");
        background.position = position
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
        bouncer.physicsBody!.isDynamic = false
        addChild(bouncer)
    }
    
    func makeBox(at position: CGPoint) {
        let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
        let box = SKSpriteNode(color: RandomColor(), size: size)
        box.zRotation = RandomCGFloat(min: 0, max: 3)
        box.position = position
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody!.isDynamic = false
        
        addChild(box)
    }
    
    func makeBall(at position: CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.name = "ball"
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody!.restitution = 0.4
        ball.position = position
        addChild(ball)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
    }
    
    func setScoreLabel(at position: CGPoint) {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = position
        
        addChild(scoreLabel)
        
    }
    
    
    func setEditLabel(at position: CGPoint) {
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = position
        addChild(editLabel)
    }
    
    // MARK: methods that handle collisions
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            if score > 0 {
                score -= 1
            }
        }
        
        
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }


}

