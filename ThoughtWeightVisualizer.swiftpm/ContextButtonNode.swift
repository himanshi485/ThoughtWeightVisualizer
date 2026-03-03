import SpriteKit

class ContextButtonNode: SKShapeNode {
    
    enum ButtonType {
        case accept, resist
    }
    
    let type: ButtonType
    let action: () -> Void
    
    init(type: ButtonType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
        super.init()
        
        let path = UIBezierPath(roundedRect: CGRect(x: -40, y: -15, width: 80, height: 30), cornerRadius: 15)
        self.path = path.cgPath
        

        let fillColor = type == .accept ? Theme.skColor(Theme.acceptFill) : Theme.skColor(Theme.resistFill)
        let strokeColor = type == .accept ? Theme.skColor(Theme.acceptStroke) : Theme.skColor(Theme.resistStroke)
        
        self.fillColor = fillColor.withAlphaComponent(0.4) // Glassy, distinct but not solid
        self.strokeColor = strokeColor
        self.lineWidth = 2
        
   
        self.glowWidth = 5 

        let label = SKLabelNode(text: type == .accept ? "Accept" : "Resist")
        label.fontSize = 14
        label.fontName = "HelveticaNeue-Medium"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
        
        self.isUserInteractionEnabled = true
     
        self.alpha = 0
        self.setScale(0.1)
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        run(appear)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        run(scaleDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(SKAction.sequence([scaleUp, SKAction.run(action)]))
    }
}
