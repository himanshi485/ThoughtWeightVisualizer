import SpriteKit

class ThoughtNode: SKShapeNode {
    
    let label: SKLabelNode
    let thought: Thought
    var resistCount: Int = 0
    
    private var glowNode: SKShapeNode!
    private var coreNode: SKShapeNode!
    
    private var acceptButton: ContextButtonNode?
    private var resistButton: ContextButtonNode?
    
    var isSelectedNode = false {
        didSet {
            if isSelectedNode {
          
                physicsBody?.velocity = .zero
                physicsBody?.angularVelocity = 0
                physicsBody?.isDynamic = false
                
                showContextButtons()
                run(SKAction.scale(to: 1.15, duration: 0.2))
                glowNode.alpha = 1.0
                glowNode.yScale = 1.2
                glowNode.xScale = 1.1
            } else {
            
                physicsBody?.isDynamic = true
                
                hideContextButtons()
                run(SKAction.scale(to: 1.0, duration: 0.2))
                glowNode.alpha = 0.6
                glowNode.yScale = 1.1
                glowNode.xScale = 1.05
            }
        }
    }
    
    init(thought: Thought) {
        self.thought = thought
        
        let l = SKLabelNode(text: thought.text)
        l.fontSize = 16
        l.fontName = "HelveticaNeue-Medium"
        l.fontColor = .white
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        l.numberOfLines = 2
        l.preferredMaxLayoutWidth = 200
        self.label = l
        
        super.init()
        
        let padding: CGFloat = 24
        let width = max(label.frame.width + padding * 2, 140)
        let height = max(label.frame.height + padding * 2, 54)
        let rect = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        let capsulePath = UIBezierPath(roundedRect: rect, cornerRadius: height/2).cgPath
        
        self.path = capsulePath
        self.lineWidth = 0
        self.strokeColor = .clear
        
        glowNode = SKShapeNode(path: capsulePath)
        glowNode.fillColor = .clear
        glowNode.strokeColor = Theme.skColor(Theme.thoughtGlow).withAlphaComponent(0.6)
        glowNode.lineWidth = 20
        glowNode.blendMode = .add
        glowNode.alpha = 0.5
        addChild(glowNode)
        
        coreNode = SKShapeNode(path: capsulePath)
        coreNode.fillColor = Theme.skColor(Theme.thoughtBubbleFill).withAlphaComponent(0.5)
        coreNode.strokeColor = Theme.skColor(Theme.thoughtBubbleStroke)
        coreNode.lineWidth = 3
        addChild(coreNode)
        
        addChild(label)
    
        physicsBody = SKPhysicsBody(polygonFrom: capsulePath)
        physicsBody?.linearDamping = 0.1
        physicsBody?.angularDamping = 0.1
        physicsBody?.restitution = 1.0
        physicsBody?.friction = 0
        physicsBody?.allowsRotation = false
        physicsBody?.mass = 0.5

        if thought.state == .resisted {

            let stroke = Theme.skColor(Theme.resistStroke)
            let fill = Theme.skColor(Theme.resistFill)
            
            coreNode.strokeColor = stroke
            coreNode.fillColor = fill.withAlphaComponent(0.5)
            glowNode.strokeColor = stroke.withAlphaComponent(0.5)
            
            physicsBody?.mass += 0.5
            physicsBody?.linearDamping += 0.2
        }
        
        startBreathing()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func startBreathing() {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 3.0)
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 3.0)
        glowNode.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
    }
    
    func applyResist() {

        physicsBody?.isDynamic = true
        
        resistCount += 1
        
        NotificationCenter.default.post(name: .thoughtResisted, object: self)

        let fill = Theme.skColor(Theme.resistFill)
        let stroke = Theme.skColor(Theme.resistStroke)
        
        let colorAction = SKAction.run {
            self.coreNode.strokeColor = stroke
            self.coreNode.fillColor = fill.withAlphaComponent(0.5)
            self.glowNode.strokeColor = stroke.withAlphaComponent(0.5)
        }
        run(colorAction)

        physicsBody?.mass += 0.5
        physicsBody?.linearDamping += 0.2

        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        run(shake)
        isSelectedNode = false 
    }
    
    func applyAccept(completion: @escaping () -> Void) {
     
        physicsBody?.isDynamic = true

        let fill = Theme.skColor(Theme.acceptFill)
        let stroke = Theme.skColor(Theme.acceptStroke)
   
        let colorAction = SKAction.run {
            self.coreNode.strokeColor = stroke
            self.coreNode.fillColor = fill.withAlphaComponent(0.5)
            self.glowNode.strokeColor = stroke.withAlphaComponent(0.5)
            self.glowNode.alpha = 0.8
        }
        run(colorAction)
        
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
        physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
        
        let fade = SKAction.fadeOut(withDuration: 1.5)
        let scale = SKAction.scale(to: 1.1, duration: 1.5)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([fade, scale])
        ])) {
            self.removeFromParent()
            completion()
            NotificationCenter.default.post(name: .thoughtAccepted, object: self)
        }
        hideContextButtons()
        
        isSelectedNode = false 
    }
    
    private func showContextButtons() {
        guard acceptButton == nil else { return }
        
        let pathRect = self.path!.boundingBox
        let btnY = -pathRect.height/2 - 25
        
        let resist = ContextButtonNode(type: .resist) { [weak self] in self?.applyResist() }
        resist.position = CGPoint(x: -60, y: btnY)
        addChild(resist)
        resistButton = resist
        
        let accept = ContextButtonNode(type: .accept) { [weak self] in
            self?.applyAccept { }
        }
        accept.position = CGPoint(x: 60, y: btnY)
        addChild(accept)
        acceptButton = accept
    }
    
    private func hideContextButtons() {
        resistButton?.removeFromParent(); resistButton = nil
        acceptButton?.removeFromParent(); acceptButton = nil
    }
}

extension Notification.Name {
    static let thoughtAccepted = Notification.Name("ThoughtAccepted")
    static let thoughtResisted = Notification.Name("ThoughtResisted")
}
