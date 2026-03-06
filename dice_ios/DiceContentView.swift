// iOS/Views/DiceContentView.swift
import SwiftUI
import SceneKit
import StoreKit
import OSLog

struct DiceContentView: View {
    @EnvironmentObject var diceState: DiceState
    @Environment(\.requestReview) private var requestReview
    @State private var showAbout = false
    @State private var reviewTracker = ReviewPromptTracker()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.yiwen.dice-ios",
        category: "评分流程"
    )

    var body: some View {
        NavigationStack {
        GeometryReader { geo in
            VStack(spacing: 24) {
                Spacer()

                // 骰子3D显示
                let diceSize = min(geo.size.width, geo.size.height * 0.62)
                let scene = DiceRenderer.createDiceScene(
                    currentNumber: diceState.currentNumber,
                    isRolling: diceState.isRolling,
                    faceRotationQuarterTurns: diceState.visibleFaceRotationQuarterTurns
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
                .accessibilityLabel(L10n.text("result.accessibility", diceState.currentNumber))

                Spacer()

                // 掷骰子按钮
                Button(action: {
                    handleRoll(source: .button)
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
        .onChange(of: diceState.currentNumber) { _, newValue in
            logger.info(
                "[评分流程] 骰子点数已更新 currentNumber=\(newValue, privacy: .public) isRolling=\(String(diceState.isRolling), privacy: .public)"
            )
        }
        .onChange(of: diceState.showResult) { _, newValue in
            logger.info(
                "[评分流程] 结果展示状态变更 showResult=\(String(newValue), privacy: .public) currentNumber=\(diceState.currentNumber, privacy: .public)"
            )
        }
        .onChange(of: diceState.visibleFaceRotationQuarterTurns) { _, newValue in
            logger.info(
                "[评分流程] 骰子可见朝向已更新 visibleFaceRotationQuarterTurns=\(newValue, privacy: .public) currentNumber=\(diceState.currentNumber, privacy: .public)"
            )
        }
        } // NavigationStack
        .onShake {
            handleRoll(source: .shake)
        }
    }

    /// 统一处理按钮与摇一摇掷骰入口，并在满足条件时触发自动评分。
    private func handleRoll(source: RollTriggerSource) {
        logger.info(
            "[评分流程] 掷骰入口 source=\(source.rawValue, privacy: .public) isRolling=\(String(diceState.isRolling), privacy: .public)"
        )

        guard !diceState.isRolling else {
            logger.info(
                "[评分流程] 掷骰入口被忽略 source=\(source.rawValue, privacy: .public) reason=骰子正在滚动"
            )
            return
        }

        withAnimation {
            diceState.rollDice()
        }

        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = source == .shake ? .heavy : .medium
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.impactOccurred()

        let shouldRequestReview = reviewTracker.recordRollAndEvaluateAutoPrompt(source: source)
        logger.info(
            "[评分流程] 自动评分判定结果 source=\(source.rawValue, privacy: .public) shouldRequest=\(String(shouldRequestReview), privacy: .public) currentCount=\(reviewTracker.currentRollCount(), privacy: .public)"
        )
        guard shouldRequestReview else { return }

        logger.info("[评分流程] 自动触发系统评分请求 source=\(source.rawValue, privacy: .public)")
        requestReview()
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
