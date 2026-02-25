// iOS/Views/DiceContentView.swift
import SwiftUI
import SceneKit

struct DiceContentView: View {
    @EnvironmentObject var diceState: DiceState
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 骰子3D显示
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
            .frame(width: UIScreen.main.bounds.width * 0.8,
                   height: UIScreen.main.bounds.width * 0.8)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(Color(UIColor.systemBackground))
            
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
                    Text("摇一摇")
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                .padding(.vertical, 15)
                .background(diceState.isRolling ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(diceState.isRolling)
            
            Spacer()
        }
        .padding()
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
