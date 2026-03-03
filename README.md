# Thought Space  
### A Physics-Based Mindfulness Visualizer for iOS

---

<p align="left">
  <img src="https://img.shields.io/badge/Platform-iOS-black?style=flat-square">
  <img src="https://img.shields.io/badge/Swift-5.x-orange?style=flat-square">
  <img src="https://img.shields.io/badge/SwiftUI-UI-blue?style=flat-square">
  <img src="https://img.shields.io/badge/SpriteKit-Physics-purple?style=flat-square">
  <img src="https://img.shields.io/badge/Offline-First-green?style=flat-square">
</p>

---

## Overview

**Thought Space** is an interactive iOS application that visualizes thoughts as physical objects in a zero-gravity environment. Built with **SwiftUI** and **SpriteKit**, the app transforms abstract mental processes into physics-based interactions.

Instead of providing passive guidance, the app allows users to *experience* how resistance increases cognitive load and how acceptance enables release.

---

## Problem

Intrusive and repetitive thoughts are common, especially under stress. Suppression often amplifies mental burden rather than reducing it. Traditional wellness apps rely heavily on text prompts or meditation timers but rarely provide experiential understanding.

---

## Solution

Each thought appears as a floating object governed by physics:

- **Resist** → The thought increases in weight, becomes denser, and harder to move.
- **Accept** → The thought becomes lighter, glows, and floats upward off screen.

This interaction model reinforces emotional regulation principles through motion, mass, and visual feedback.

---

## Core Features

### Interactive Thought Space
- Zero-gravity physics simulation (SpriteKit)
- Boundary constraints to maintain on-screen interaction
- Dynamic neon pill-shaped thought nodes
- Tap to select and interact

### Thought Actions
- **Resist:** increases mass, deepens color, simulates emotional burden
- **Accept:** reduces mass, upward impulse, fade and removal animation

### Add Thought
- Modal input interface
- Real-time character counter
- Instant spawning into simulation

### History & Persistence
- Timestamped thought history
- Status tracking (Neutral, Resisted, Accepted)
- Local persistence using JSON encoding + UserDefaults
- Delete functionality

### Onboarding
- Animated introduction explaining the core metaphor
- Reset logic when all thoughts are cleared

---

## Technical Architecture

- **SwiftUI** — Declarative UI and state management
- **SpriteKit** — Physics engine, motion, collisions, impulses
- **UserDefaults + Codable** — Lightweight offline persistence
- Custom `SKShapeNode` subclasses for dynamic pill-shaped thought nodes

---

## Design Principles

- Minimal interface focused on interaction
- Dark cosmic theme to reduce visual strain
- Neon glow to emphasize state changes
- Smooth, non-chaotic motion
- Fully offline operation

---

## Project Structure

```plaintext
ThoughtSpace/
├── ContentView.swift
├── ThoughtScene.swift
├── ThoughtNode.swift
├── OnboardingView.swift
├── HistoryView.swift
├── Models/
└── Persistence/
```

---

## Privacy

- No data collection  
- No network usage  
- No third-party libraries  
- All data stored locally on device  

---

## Motivation

This project was inspired by the idea that resisting thoughts increases their perceived weight, while acceptance reduces their intensity. By visualizing this principle through physics, the app provides a tangible way to understand emotional processing.
