import Foundation
import SwiftUI

enum ThoughtState: String, Codable {
    case neutral
    case accepted
    case resisted
}

struct Thought: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var text: String
    var weight: CGFloat // 1.0 = normal, higher = heavier/slower
    var state: ThoughtState = .neutral
    var dateCreated: Date
}
