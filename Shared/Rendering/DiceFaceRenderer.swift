#if os(macOS)
import AppKit
import SceneKit
typealias PlatformImage = NSImage
#else
import UIKit
import SceneKit
typealias PlatformImage = UIImage
#endif

class DiceFaceRenderer {
    private static let numbers = [1, 3, 6, 4, 5, 2]
    private static let cachedMaterials: [SCNMaterial] = numbers.map { createDiceMaterial(for: $0) }

    static func createDiceMaterials() -> [SCNMaterial] {
        cachedMaterials.map { $0.copy() as! SCNMaterial }
    }
    
    static func dotsForNumber(_ number: Int) -> [CGPoint] {
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
    
    static func createDiceFace(number: Int) -> PlatformImage {
        #if os(macOS)
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
        
        #else
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)  // 改为 true，表示不透明

        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        // 绘制白色背景
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))

        // 绘制黑色点
        UIColor.black.setFill()
        let dots = dotsForNumber(number)
        let dotSize = CGSize(width: 80, height: 80)

        for position in dots {
            let rect = CGRect(
                x: position.x * size.width - dotSize.width/2,
                y: position.y * size.height - dotSize.height/2,
                width: dotSize.width,
                height: dotSize.height
            )
            context.fillEllipse(in: rect)
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        UIGraphicsEndImageContext()

        // 确保图像有效
        if image.size.width == 0 || image.size.height == 0 {
            #if DEBUG
            print("Warning: Generated image has zero size")
            #endif
            return UIImage()
        }

        return image
        #endif
    }
    
    private static func createDiceMaterial(for number: Int) -> SCNMaterial {
        let material = SCNMaterial()
        
        // 首先设置基本颜色
        #if os(macOS)
        material.diffuse.contents = NSColor.white
        #else
        material.diffuse.contents = UIColor.white
        #endif
        
        // 创建和设置图像
        let image = createDiceFace(number: number)
        material.diffuse.contents = image
        
        // 添加其他必要的材质属性
        material.locksAmbientWithDiffuse = true
        material.lightingModel = .blinn
        material.diffuse.magnificationFilter = .linear
        material.diffuse.minificationFilter = .linear
        material.diffuse.mipFilter = .linear
        
        return material
    }
}
