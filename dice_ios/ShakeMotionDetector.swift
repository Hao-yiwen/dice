import SwiftUI
import UIKit

/// 通过第一响应者接收摇一摇。零尺寸视图不会参与点击，但必须能 `becomeFirstResponder`，
/// 否则 `motionEnded` 不会投递到这里（这是 `UIWindow` 全局覆盖之外的正确替代）。
private final class ShakeDetectingView: UIView {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        onShake?()
    }
}

private struct ShakeMotionDetector: UIViewRepresentable {
    let onShake: () -> Void

    func makeUIView(context: Context) -> ShakeDetectingView {
        let view = ShakeDetectingView()
        view.backgroundColor = .clear
        view.isAccessibilityElement = false
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeDetectingView, context: Context) {
        uiView.onShake = onShake
        if uiView.window != nil, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
}

extension View {
    /// 在可见界面中监听设备摇一摇，不依赖全局 `UIWindow` 方法覆盖。
    func onShake(perform action: @escaping () -> Void) -> some View {
        background {
            ShakeMotionDetector(onShake: action)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        }
    }
}
