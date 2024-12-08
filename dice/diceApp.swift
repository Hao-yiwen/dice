import SwiftUI
import SceneKit

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

class DiceState: ObservableObject {
    @Published var currentNumber: Int = 1
    @Published var isRolling: Bool = false
    @Published var showResult: Bool = false
    
    func rollDice() {
        isRolling = true
        showResult = false
        
        var randomGenerator = SystemRandomNumberGenerator()
        currentNumber = Int.random(in: 1...6, using: &randomGenerator)
        
        print("""
        骰子状态:
        - 生成的随机数: \(currentNumber)
        - 预期朝上的面: \(currentNumber)
        """)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRolling = false
            self.showResult = true
        }
    }
}

struct DiceMenuView: View {
    @EnvironmentObject var diceState: DiceState
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 骰子3D显示
            SceneView(
                scene: createDiceScene(),
                pointOfView: createCamera(),
                options: [.autoenablesDefaultLighting]
            )
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 掷骰子按钮
            Button(action: { diceState.rollDice() }) {
                HStack {
                    Image(systemName: "dice")
                    Text("摇一摇")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(diceState.isRolling ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(diceState.isRolling)
            
            HStack {
                Spacer()
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                .popover(isPresented: $showingSettings) {
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        HStack {
                            Image(systemName: "power")
                            Text("退出")
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .frame(width: 260)
    }
    
    private func createDiceScene() -> SCNScene {
        let scene = SCNScene()
        let diceNode = createDiceNode()
        scene.rootNode.addChildNode(diceNode)
        return scene
    }
    
        // 添加创建骰子面的函数
        private func createDiceFace(number: Int) -> NSImage {
            let size = NSSize(width: 512, height: 512)
            let image = NSImage(size: size)
            
            image.lockFocus()
            
            // 绘制白色背景
            NSColor.white.setFill()
            NSRect(origin: .zero, size: size).fill()
            
            // 绘制黑色点
            NSColor.black.setFill()
            let dots = dotsForNumber(number)
            let dotSize = CGSize(width: 80, height: 80)
            
            for position in dots {
                let rect = NSRect(
                    x: position.x * size.width - dotSize.width/2,
                    y: position.y * size.height - dotSize.height/2,
                    width: dotSize.width,
                    height: dotSize.height
                )
                NSBezierPath(ovalIn: rect).fill()
            }
            
            image.unlockFocus()
            return image
        }
        
        private func dotsForNumber(_ number: Int) -> [CGPoint] {
            switch number {
            case 1: return [CGPoint(x: 0.5, y: 0.5)]
            case 2: return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.7, y: 0.7)]
            case 3: return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.7, y: 0.7)]
            case 4: return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.3, y: 0.7),
                           CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.7, y: 0.7)]
            case 5: return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.3, y: 0.7),
                           CGPoint(x: 0.5, y: 0.5),
                           CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.7, y: 0.7)]
            case 6: return [CGPoint(x: 0.3, y: 0.3), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.3, y: 0.7),
                           CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.7, y: 0.7)]
            default: return []
            }
        }
    
    private func createDiceMaterials() -> [SCNMaterial] {
        // SceneKit 的六个面的顺序是：
        // 1. 前面（-Z）
        // 2. 右面（+X）
        // 3. 后面（+Z）
        // 4. 左面（-X）
        // 5. 顶面（+Y）
        // 6. 底面（-Y）
        
        // 让我们确保当骰子不旋转时（角度都是0）：
        // - 1在前面（-Z）
        // - 3在右面（+X）
        // - 6在后面（+Z）
        // - 4在左面（-X）
        // - 5在顶面（+Y）
        // - 2在底面（-Y）
        let numbers = [1, 3, 6, 4, 5, 2]
        return numbers.map { createDiceMaterial(for: $0) }
    }

    private func getSimpleRotationForNumber(_ number: Int) -> SCNVector3 {
        // 当我们想要某个数字朝上时，需要将对应的面旋转到顶部（+Y）位置
        switch number {
        case 1:
            // 将前面翻转到顶部
            return SCNVector3(-Float.pi/2, 0, 0)
        case 2:
            // 将底面翻转到顶部
            return SCNVector3(Float.pi, 0, 0)
        case 3:
            // 将右面翻转到顶部
            return SCNVector3(0, 0, Float.pi/2)
        case 4:
            // 将左面翻转到顶部
            return SCNVector3(0, 0, -Float.pi/2)
        case 5:
            // 5已经在顶部，不需要旋转
            return SCNVector3(0, 0, 0)
        case 6:
            // 将后面翻转到顶部
            return SCNVector3(Float.pi/2, 0, 0)
        default:
            return SCNVector3(0, 0, 0)
        }
    }
    
    private func createDiceNode() -> SCNNode {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.materials = createDiceMaterials()
        
        let diceNode = SCNNode(geometry: box)
        diceNode.position = SCNVector3(0, 0, 0)
        
        if diceState.isRolling {
            // 先进行随机旋转动画
            let rotateAction = SCNAction.rotateBy(
                x: CGFloat.random(in: 8...12) * .pi,
                y: CGFloat.random(in: 8...12) * .pi,
                z: CGFloat.random(in: 8...12) * .pi,
                duration: 1.0
            )
            
            // 动画结束后，旋转到目标角度
            let finalRotation = getSimpleRotationForNumber(diceState.currentNumber)
            let finalAction = SCNAction.rotateTo(
                x: CGFloat(finalRotation.x),
                y: CGFloat(finalRotation.y),
                z: CGFloat(finalRotation.z),
                duration: 0.2
            )
            
            diceNode.runAction(SCNAction.sequence([rotateAction, finalAction]))
        } else {
            diceNode.eulerAngles = getSimpleRotationForNumber(diceState.currentNumber)
        }
        
        return diceNode
    }
    private func createDiceMaterial(for number: Int) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.white
        material.diffuse.contents = createDiceFace(number: number)
        return material
    }
    
    private func createCamera() -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 2, 4)
        cameraNode.eulerAngles = SCNVector3(x: -0.5, y: 0, z: 0)
        return cameraNode
    }
}
