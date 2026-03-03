import SpriteKit
import SwiftUI

class ThoughtScene: SKScene {
 
    var onAccept: ((UUID) -> Void)?
    var onResist: ((UUID) -> Void)?

    let bottomSafeArea: CGFloat = 110
 
    private var thoughtNodes: [UUID: ThoughtNode] = [:]
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true
        physicsWorld.gravity = .zero
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleNodeAccepted(_:)), name: .thoughtAccepted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNodeResisted(_:)), name: .thoughtResisted, object: nil)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0 else { return }
    
        let safeFrame = CGRect(
            x: 0,
            y: bottomSafeArea,
            width: size.width,
            height: size.height - bottomSafeArea
        )
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: safeFrame)
        physicsBody?.friction = 0
        physicsBody?.restitution = 1.0
    }
    
    func syncThoughts(_ dataThoughts: [Thought]) {
        let dataIDs = Set(dataThoughts.map { $0.id })
      
        for (id, node) in thoughtNodes {
            if !dataIDs.contains(id) {
       
                if node.parent != nil {
                     node.removeFromParent()
                }
                thoughtNodes.removeValue(forKey: id)
            }
        }
 
        for thought in dataThoughts {
            if thoughtNodes[thought.id] == nil {
                spawnThought(thought)
            }
        }
    }
    
    private func spawnThought(_ thought: Thought) {
        let node = ThoughtNode(thought: thought)
        thoughtNodes[thought.id] = node

        let midX = size.width/2
        let availableHeight = size.height - bottomSafeArea
        let midY = bottomSafeArea + (availableHeight / 2)
        
        let rangeX = size.width/4
        let rangeY = availableHeight/4
        
        node.position = CGPoint(
            x: CGFloat.random(in: (midX-rangeX)...(midX+rangeX)),
            y: CGFloat.random(in: (midY-rangeY)...(midY+rangeY))
        )
        
        addChild(node)
      
        node.physicsBody?.applyImpulse(randomVector(magnitude: 20))
  
        node.alpha = 0
        node.setScale(0.5)
        node.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ]))
    }

    @objc func handleNodeAccepted(_ notification: Notification) {
        guard let node = notification.object as? ThoughtNode else { return }
        onAccept?(node.thought.id)
    }
    @objc func handleNodeResisted(_ notification: Notification) {
        guard let node = notification.object as? ThoughtNode else { return }
        onResist?(node.thought.id)
    }

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            guard let body = node.physicsBody else { continue }
            
            let speed = sqrt(body.velocity.dx*body.velocity.dx + body.velocity.dy*body.velocity.dy)
            if speed < 10 { body.applyImpulse(randomVector(magnitude: 5)) }
            else if speed < 30 { body.applyForce(randomVector(magnitude: 2)) }
            
            let margin: CGFloat = 60
            let pushStrength: CGFloat = 30
            
            if node.position.x < margin { body.applyForce(CGVector(dx: pushStrength, dy: 0)) }
            if node.position.x > size.width - margin { body.applyForce(CGVector(dx: -pushStrength, dy: 0)) }

            if node.position.y < bottomSafeArea + margin {
                body.applyForce(CGVector(dx: 0, dy: pushStrength * 1.5))
            }
            
            if node.position.y > size.height - margin { body.applyForce(CGVector(dx: 0, dy: -pushStrength)) }
        }
    }
    
    private func randomVector(magnitude: CGFloat) -> CGVector {
        let angle = CGFloat.random(in: 0...(.pi * 2))
        return CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        if loc.y < bottomSafeArea { return }
        
        if nodes(at: loc).contains(where: { $0 is ContextButtonNode }) { return }
        
        if let thoughtNode = nodes(at: loc).first(where: { $0 is ThoughtNode }) as? ThoughtNode {
            children.forEach { ($0 as? ThoughtNode)?.isSelectedNode = false }
            thoughtNode.isSelectedNode.toggle()
        } else {
            children.forEach { ($0 as? ThoughtNode)?.isSelectedNode = false }
        }
    }
}
