import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @StateObject private var store = ThoughtStore()
    
    @State private var scene: ThoughtScene = {
        let s = ThoughtScene()
        s.scaleMode = .resizeFill
        return s
    }()
    
    @State private var showAddThought = false
    @State private var showHistory = false
    @State private var newThoughtText = ""
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(onFinish: {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                })
                .transition(.opacity)
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Theme.backgroundStart, Theme.backgroundEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    StarsOverlay()
                    
                    if store.thoughts.isEmpty {
                        WelcomeView(
                            onStart: { showAddThought = true },
                            onShowHistory: { showHistory = true }
                        )
                        .transition(.opacity)
                    } else {
                        GeometryReader { proxy in
                            SpriteView(scene: scene, options: [.allowsTransparency])
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .onAppear {
                                    scene.size = proxy.size
                                    connectScene()
                                }
                                .onChange(of: proxy.size) { newSize in scene.size = newSize }
                                .onChange(of: store.thoughts) { newThoughts in
                                    scene.syncThoughts(newThoughts)
                                }
                        }
                        .ignoresSafeArea()
                        .transition(.opacity)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { showHistory = true }) {
                                Image(systemName: "list.bullet.rectangle.portrait")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(12)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .padding(.top, 50)
                            .padding(.trailing, 24)
                        }
                        
                        Spacer()
                        
                        if !store.thoughts.isEmpty {
                            VStack {
                                HStack {
                                    Text("Tap bubbles to interact")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                                    .padding(.leading, 24)
                                    .opacity(0.8)
                                    
                                    Spacer()
                                    
                                    Button(action: { showAddThought = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus")
                                            Text("Add")
                                        }
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Material.thin)
                                        .cornerRadius(30)
                                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Theme.thoughtBubbleStroke.opacity(0.5)))
                                        .foregroundColor(.white)
                                    }
                                    .padding(.trailing, 24)
                                }
                                .padding(.bottom, 24)
                            }
                        }
                    }
                    
                    if showAddThought {
                        AddThoughtModal(
                            isPresented: $showAddThought,
                            text: $newThoughtText,
                            onAdd: {
                                store.addThought(newThoughtText)
                            }
                        )
                    }
                }
                .fullScreenCover(isPresented: $showHistory) {
                    ThoughtListView(store: store, isPresented: $showHistory)
                }
            }
        }
        .onAppear {
            if store.thoughts.isEmpty && store.history.isEmpty {
                hasSeenOnboarding = false
            }
        }
    }
    
    func connectScene() {
        scene.syncThoughts(store.thoughts)
        scene.onAccept = { id in
            store.markAsAccepted(id: id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                store.removeThought(id: id)
            }
        }
        scene.onResist = { id in
            store.resistThought(id: id)
        }
    }
}

struct WelcomeView: View {
    var onStart: () -> Void
    var onShowHistory: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(Theme.thoughtGlow)
                .shadow(color: Theme.thoughtGlow, radius: 20)
            
            VStack(spacing: 10) {
                Text("Thought Space")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Let's acknowledge your thought.")
                    .font(.title3)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onStart) {
                Text("Add a Thought")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Theme.thoughtBubbleFill)
                    .cornerRadius(30)
                    .shadow(color: Theme.thoughtBubbleStroke, radius: 15)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

struct StarsOverlay: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0...80 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let s = Double.random(in: 1...1.5)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: s, height: s)), with: .color(.white.opacity(0.3)))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct AddThoughtModal: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    var onAdd: () -> Void
    
    let limit = 100
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add New Thought")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Text("What's on your mind?")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: { isPresented = false; text = "" }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.bottom, 8)
                
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Enter your thought...")
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.top, 12)
                            .padding(.leading, 12)
                    }
                    
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .accentColor(Theme.thoughtGlow)
                        .frame(height: 120)
                        .padding(8)
                        .onChange(of: text) { newValue in
                            if newValue.count > limit {
                                text = String(newValue.prefix(limit))
                            }
                        }
                }
                .background(Color(red: 0.2, green: 0.1, blue: 0.3))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.thoughtGlow.opacity(0.3), lineWidth: 1))
                
                HStack {
                    Spacer()
                    Text("\(text.count)/\(limit)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(spacing: 16) {
                    Button(action: { isPresented = false; text = "" }) {
                        Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    
                    Button(action: {
                        if !text.isEmpty { onAdd(); isPresented = false; text = "" }
                    }) {
                        Text("Add to Space")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.thoughtBubbleFill)
                        .cornerRadius(25)
                        .shadow(color: Theme.thoughtBubbleStroke.opacity(0.5), radius: 10, y: 5)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(width: 340)
            .background(
                Color(red: 0.12, green: 0.05, blue: 0.2)
            )
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 40, x: 0, y: 20)
        }
    }
}

struct ThoughtListView: View {
    @ObservedObject var store: ThoughtStore
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundStart, Theme.backgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Your History")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                if store.history.isEmpty {
                    Spacer()
                    Text("No thoughts recorded yet.")
                    .foregroundColor(Theme.secondaryText)
                    .font(.title3)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.history.reversed()) { thought in
                                ThoughtRow(thought: thought, onDelete: {
                                    withAnimation {
                                        store.deleteFromHistory(id: thought.id)
                                    }
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct ThoughtRow: View {
    let thought: Thought
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(thought.text)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
                
                HStack {
                    Text(thought.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    StatusBadge(state: thought.state)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.resistStroke.opacity(0.8))
                        .padding(8)
                        .background(Color(white: 0.1))
                        .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(rowBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .stroke(rowBorder, lineWidth: 1)
        )
    }
    
    var rowBackground: Color {
        switch thought.state {
        case .accepted: return Theme.acceptFill.opacity(0.2)
        case .resisted: return Theme.resistFill.opacity(0.2)
        case .neutral: return Theme.thoughtBubbleFill.opacity(0.2)
        }
    }
    
    var rowBorder: Color {
        switch thought.state {
        case .accepted: return Theme.acceptStroke.opacity(0.5)
        case .resisted: return Theme.resistStroke.opacity(0.5)
        case .neutral: return Theme.thoughtBubbleStroke.opacity(0.5)
        }
    }
}

struct StatusBadge: View {
    let state: ThoughtState
    
    var body: some View {
        Text(state.rawValue.capitalized)
        .font(.caption.bold())
        .foregroundColor(foreColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(foreColor.opacity(0.2))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(foreColor, lineWidth: 1))
    }
    
    var foreColor: Color {
        switch state {
        case .accepted: return Theme.acceptStroke
        case .resisted: return Theme.resistStroke
        case .neutral: return Theme.thoughtBubbleStroke
        }
    }
}
