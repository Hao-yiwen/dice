import SceneKit

class DiceRenderer {
    static func createDiceNode(
        currentNumber: Int,
        isRolling: Bool,
        materials: [SCNMaterial]
    ) -> SCNNode {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.materials = materials
        
        let diceNode = SCNNode(geometry: box)
        diceNode.position = SCNVector3(0, 0, 0)
        
        if isRolling {
            let rotateAction = SCNAction.rotateBy(
                x: CGFloat.random(in: 8...12) * .pi,
                y: CGFloat.random(in: 8...12) * .pi,
                z: CGFloat.random(in: 8...12) * .pi,
                duration: 1.0
            )
            
            let finalRotation = getSimpleRotationForNumber(currentNumber)
            let finalAction = SCNAction.rotateTo(
                x: CGFloat(finalRotation.x),
                y: CGFloat(finalRotation.y),
                z: CGFloat(finalRotation.z),
                duration: 0.2
            )
            
            diceNode.runAction(SCNAction.sequence([rotateAction, finalAction]))
        } else {
            diceNode.eulerAngles = getSimpleRotationForNumber(currentNumber)
        }
        
        return diceNode
    }
    
    static func getSimpleRotationForNumber(_ number: Int) -> SCNVector3 {
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
    
    static func createCamera() -> SCNNode {
        #if os(macOS)
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(0, 2, 4)
            cameraNode.eulerAngles = SCNVector3(x: -0.5, y: 0, z: 0)
            return cameraNode
        #else
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.zFar = 100
            cameraNode.camera?.zNear = 0.1
            cameraNode.position = SCNVector3(0, 4, 2.5)  // 调高相机位置，减小z值
            cameraNode.eulerAngles = SCNVector3(x: -0.9, y: 0, z: 0)  // 增大俯视角度
            
            // 添加约束以确保相机始终看向骰子
            let constraint = SCNLookAtConstraint(target: nil)
            constraint.isGimbalLockEnabled = true
            cameraNode.constraints = [constraint]
            
            return cameraNode
        #endif
    }
    
    static func createDiceScene(currentNumber: Int, isRolling: Bool) -> SCNScene {
        #if os(macOS)
        let scene = SCNScene()
        let diceNode = createDiceNode(
            currentNumber: currentNumber,
            isRolling: isRolling,
            materials: DiceFaceRenderer.createDiceMaterials()
        )
        scene.rootNode.addChildNode(diceNode)
        return scene
        #else
        let scene = SCNScene()
            
        // 添加环境光
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 150  // 稍微增加环境光强度
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // 主方向光
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 600
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        // 将光源节点放在 y=8 的位置
        directionalNode.position = SCNVector3(x: 0, y: 8, z: 0)
        // **关键：让灯光方向朝下（默认是沿 -Z）**
        directionalNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        // 将其加入场景
        scene.rootNode.addChildNode(directionalNode)
        // 添加骰子节点
        let diceNode = createDiceNode(
            currentNumber: currentNumber,
            isRolling: isRolling,
            materials: DiceFaceRenderer.createDiceMaterials()
        )

        diceNode.scale = SCNVector3(1.5, 1.5, 1.5)
        
        // 设置背景颜色
        // scene.background.contents = UIColor.white
        
        scene.rootNode.addChildNode(diceNode)
        return scene
        #endif
    }
}
