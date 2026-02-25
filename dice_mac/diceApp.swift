import SwiftUI

@main
struct DiceMenuBarApp: App {
    @StateObject private var diceState = DiceState()
    
    var body: some Scene {
        MenuBarExtra(L10n.text("app.name"), systemImage: "dice") {
            DiceMenuView()
                .environmentObject(diceState)
        }
        .menuBarExtraStyle(.window)
    }
}
