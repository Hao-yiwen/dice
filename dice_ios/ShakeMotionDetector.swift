import SwiftUI
import UIKit

private final class ShakeMotionViewController: UIViewController {
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        onShake?()
    }
}

private struct ShakeMotionDetector: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeMotionViewController {
        let controller = ShakeMotionViewController()
        controller.onShake = onShake
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeMotionViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

extension View {
    /// 在可见界面中监听设备摇一摇，不依赖全局 `UIWindow` 方法覆盖。
    func onShake(perform action: @escaping () -> Void) -> some View {
        background {
            ShakeMotionDetector(onShake: action)
                .frame(width: 0, height: 0)
        }
    }
}