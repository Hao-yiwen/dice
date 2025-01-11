// iOS/DiceApp.swift
import SwiftUI

@main
struct DiceApp: App {
    @StateObject private var diceState = DiceState()
    
    var body: some Scene {
        WindowGroup {
            DiceContentView()
                .environmentObject(diceState)
        }
    }
}
