import Foundation
import SwiftUI

class ThoughtStore: ObservableObject {
    @Published var thoughts: [Thought] = []
    
    @Published var history: [Thought] = []
    
    private let saveKey = "SavedThoughtsV2"
    
    init() {
        loadThoughts()
    }
    
    func addThought(_ text: String) {
        let newThought = Thought(text: text, weight: 1.0, state: .neutral, dateCreated: Date())
        thoughts.append(newThought)
        history.append(newThought)
        save()
    }
    
    func markAsAccepted(id: UUID) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].state = .accepted
        }
        if let index = thoughts.firstIndex(where: { $0.id == id }) {
            thoughts[index].state = .accepted
        }
        save()
    }
    
    func removeThought(id: UUID) {
        thoughts.removeAll { $0.id == id }
    }
    
    func deleteFromHistory(id: UUID) {
        history.removeAll { $0.id == id }
        thoughts.removeAll { $0.id == id }
        save()
    }
    
    func resistThought(id: UUID) {
        if let index = thoughts.firstIndex(where: { $0.id == id }) {
            thoughts[index].state = .resisted
            thoughts[index].weight += 0.5
        }
        
        if let hIndex = history.firstIndex(where: { $0.id == id }) {
            history[hIndex].state = .resisted
            history[hIndex].weight += 0.5
        }
        
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadThoughts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Thought].self, from: data) {
            history = decoded
            thoughts = history.filter { $0.state != .accepted }
        }
    }
}
