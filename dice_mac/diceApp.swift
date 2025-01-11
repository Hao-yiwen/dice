import SwiftUI

@main
struct DiceMenuBarApp: App {
    @StateObject private var diceState = DiceState()
    
    var body: some Scene {
        MenuBarExtra("骰子", systemImage: "dice") {
            DiceMenuView()
                .environmentObject(diceState)
        }
        .menuBarExtraStyle(.window)
    }
}
