// iOS/Views/DiceContentView.swift
import SwiftUI
import SceneKit

struct DiceContentView: View {
    @EnvironmentObject var diceState: DiceState
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
        GeometryReader { geo in
            VStack(spacing: 24) {
                Spacer()

                // 骰子3D显示
                let diceSize = min(geo.size.width, geo.size.height * 0.62)
                let scene = DiceRenderer.createDiceScene(
                    currentNumber: diceState.currentNumber,
                    isRolling: diceState.isRolling
                )
                let camera = DiceRenderer.createCamera()
                SceneView(
                    scene: scene,
                    pointOfView: camera,
                    options: [
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                    ]
                )
                .frame(width: diceSize, height: diceSize)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Spacer()

                // 掷骰子按钮
                Button(action: {
                    debugLog("Rolling Dice")
                    withAnimation {
                        diceState.rollDice()
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    HStack {
                        Image(systemName: "dice")
                        Text(L10n.text("action.roll"))
                    }
                    .font(.title3)
                    .frame(maxWidth: diceSize - 32)
                    .padding(.vertical, 16)
                    .background(diceState.isRolling ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(diceState.isRolling)

                Spacer().frame(height: 16)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .navigationTitle(L10n.text("app.name"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAbout = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        } // NavigationStack
        .onShake {
            if !diceState.isRolling {
                debugLog("Shake detected - triggering roll")
                diceState.rollDice()
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
    }
}


// 摇一摇检测扩展
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

// 允许检测摇一摇手势
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

private func debugLog(_ message: @autoclosure () -> String) {
    #if DEBUG
    print(message())
    #endif
}
