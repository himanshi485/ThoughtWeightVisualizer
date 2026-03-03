import SwiftUI

struct Theme {
 
    static let backgroundStart = Color(red: 0.02, green: 0.0, blue: 0.05)
    static let backgroundEnd = Color(red: 0.0, green: 0.0, blue: 0.02)
    

    static let thoughtBubbleFill = Color(red: 0.29, green: 0.08, blue: 0.55)

    static let thoughtBubbleStroke = Color(red: 0.5, green: 0.2, blue: 0.9)

    static let thoughtGlow = Color(red: 0.6, green: 0.2, blue: 1.0)
    

    static let resistFill = Color(red: 0.2, green: 0.05, blue: 0.1)
    static let resistStroke = Color(red: 0.8, green: 0.2, blue: 0.3)
   
    static let acceptFill = Color(red: 0.0, green: 0.3, blue: 0.25)
    static let acceptStroke = Color(red: 0.0, green: 0.8, blue: 0.6)
    
    static let textColor = Color.white
    static let secondaryText = Color.white.opacity(0.6)
    
    static func skColor(_ color: Color) -> UIColor {
        return UIColor(color)
    }
}
