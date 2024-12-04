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
    @Published var rollHistory: [Int] = []
    
    func rollDice() {
        isRolling = true
        showResult = false
        // 在开始投掷时生成随机数
        currentNumber = Int.random(in: 1...6)
        print("Generated number: \(currentNumber)") // 调试用
    }
}

struct DiceMenuView: View {
    @EnvironmentObject var diceState: DiceState
    
    var body: some View {
        VStack(spacing: 16) {
            SceneView(
                scene: createDiceScene(),
                pointOfView: createCamera(),
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(radius: 5)
            
            Button(action: {
                diceState.rollDice()
            }) {
                HStack {
                    Image(systemName: "dice")
                        .font(.title2)
                    Text("掷骰子")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(diceState.isRolling ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .disabled(diceState.isRolling)
            
            if diceState.showResult {
                VStack(spacing: 8) {
                    Text("当前点数")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(diceState.currentNumber)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.vertical, 8)
                .transition(.scale.combined(with: .opacity))
            }
            
            if !diceState.rollHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("历史记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(diceState.rollHistory, id: \.self) { number in
                            Text("\(number)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.blue.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity)
            }
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("退出")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 260)
        .animation(.spring(response: 0.3), value: diceState.showResult)
        .animation(.spring(response: 0.3), value: diceState.rollHistory)
    }
    
    private func createDiceScene() -> SCNScene {
        let scene = SCNScene()
        let diceNode = createDiceNode()
        scene.rootNode.addChildNode(diceNode)
        addBoundaries(to: scene)
        return scene
    }
    
    private func addBoundaries(to scene: SCNScene) {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = NSColor.clear
        let floorNode = SCNNode(geometry: floor)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(floorNode)
        
        let wallSize = 10.0
        let wallThickness = 0.1
        
        let wallPositions = [
            SCNVector3(0, wallSize/2, wallSize/2),
            SCNVector3(0, wallSize/2, -wallSize/2),
            SCNVector3(wallSize/2, wallSize/2, 0),
            SCNVector3(-wallSize/2, wallSize/2, 0)
        ]
        
        let wallRotations = [
            SCNVector3(0, 0, 0),
            SCNVector3(0, CGFloat.pi, 0),
            SCNVector3(0, CGFloat.pi/2, 0),
            SCNVector3(0, -CGFloat.pi/2, 0)
        ]
        
        for (position, rotation) in zip(wallPositions, wallRotations) {
            let wall = SCNBox(width: wallSize, height: wallSize, length: CGFloat(wallThickness), chamferRadius: 0)
            wall.firstMaterial?.diffuse.contents = NSColor.clear
            let wallNode = SCNNode(geometry: wall)
            wallNode.position = position
            wallNode.eulerAngles = rotation
            wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            scene.rootNode.addChildNode(wallNode)
        }
    }
    
    private func createDiceNode() -> SCNNode {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        let materials = createDiceMaterials()
        box.materials = materials
        
        let diceNode = SCNNode(geometry: box)
        diceNode.position = SCNVector3(0, 0.5, 0)
        
        diceNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        diceNode.physicsBody?.mass = 1.0
        diceNode.physicsBody?.friction = 0.5
        diceNode.physicsBody?.restitution = 0.3
        
        if diceState.isRolling {
            let power = CGFloat(2.0)
            
            // 初始随机旋转和力的应用保持不变
            diceNode.physicsBody?.applyTorque(
                SCNVector4(
                    CGFloat.random(in: -1...1) * power,
                    CGFloat.random(in: -1...1) * power,
                    CGFloat.random(in: -1...1) * power,
                    CGFloat.pi * 2
                ),
                asImpulse: true
            )
            
            diceNode.physicsBody?.applyForce(
                SCNVector3(
                    CGFloat.random(in: -1...1),
                    CGFloat(3.0),
                    CGFloat.random(in: -1...1)
                ),
                asImpulse: true
            )
            
            // 在动画快结束时，让骰子回到中心位置并显示正确的点数
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.2
                
                // 重置位置到中心
                diceNode.position = SCNVector3(0, 0.5, 0)
                
                // 根据实际点数设置旋转
                diceNode.eulerAngles = self.getEulerAnglesForNumber(self.diceState.currentNumber)
                
                SCNTransaction.commit()
            }
        }
        
        return diceNode
    }
    
    // 添加一个新方法来获取对应点数的欧拉角
    private func getEulerAnglesForNumber(_ number: Int) -> SCNVector3 {
        switch number {
        case 1:
            return SCNVector3(0, 0, CGFloat.pi)
        case 2:
            return SCNVector3(CGFloat.pi/2, 0, 0)
        case 3:
            return SCNVector3(0, -CGFloat.pi/2, 0)
        case 4:
            return SCNVector3(0, CGFloat.pi/2, 0)
        case 5:
            return SCNVector3(-CGFloat.pi/2, 0, 0)
        case 6:
            return SCNVector3(0, 0, 0)
        default:
            return SCNVector3(0, 0, 0)
        }
    }
    
    private func getRotationMatrixForNumber(_ number: Int) -> SCNMatrix4 {
        // 骰子对面点数和为7（1对6，2对5，3对4）
        switch number {
        case 1:
            return SCNMatrix4MakeRotation(CGFloat.pi, 0, 0, 1) // 显示1
        case 2:
            return SCNMatrix4MakeRotation(CGFloat.pi/2, 1, 0, 0) // 显示2
        case 3:
            return SCNMatrix4MakeRotation(0, 0, -CGFloat.pi/2, 0) // 显示3
        case 4:
            return SCNMatrix4MakeRotation(0, 0, CGFloat.pi/2, 0) // 显示4
        case 5:
            return SCNMatrix4MakeRotation(-CGFloat.pi/2, 1, 0, 0) // 显示5
        case 6:
            return SCNMatrix4Identity // 显示6
        default:
            return SCNMatrix4Identity
        }
    }
    
    private func createDiceMaterials() -> [SCNMaterial] {
        // 确保材质顺序与骰子面对应
        let numbers = [6, 5, 1, 2, 3, 4] // 右、左、上、下、前、后
        
        return numbers.map { number in
            let material = SCNMaterial()
            material.diffuse.contents = createDiceFace(number: number)
            material.specular.contents = NSColor.white
            material.locksAmbientWithDiffuse = true
            return material
        }
    }
    
    private func createDiceFace(number: Int) -> NSImage {
        let size = NSSize(width: 512, height: 512)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
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
    
    private func createCamera() -> SCNNode {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 3, z: 4)
        cameraNode.eulerAngles = SCNVector3(x: -CGFloat.pi/6, y: 0, z: 0)
        return cameraNode
    }
}

#Preview {
    DiceMenuView()
        .environmentObject(DiceState())
}
