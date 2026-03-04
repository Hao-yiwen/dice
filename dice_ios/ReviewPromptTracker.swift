import Foundation
import OSLog

/// 掷骰触发来源，用于日志区分按钮与摇一摇入口。
enum RollTriggerSource: String {
    case button
    case shake
}

/// 管理评分触发计数与自动评分状态。
final class ReviewPromptTracker {
    private enum Keys {
        static let rollCount = "review.roll_count"
        static let autoPromptedOnce = "review.auto_prompted_once"
    }

    private let userDefaults: UserDefaults
    private let autoPromptThreshold: Int
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.yiwen.dice-ios",
        category: "评分流程"
    )

    init(userDefaults: UserDefaults = .standard, autoPromptThreshold: Int = 3) {
        self.userDefaults = userDefaults
        self.autoPromptThreshold = autoPromptThreshold
    }

    func currentRollCount() -> Int {
        userDefaults.integer(forKey: Keys.rollCount)
    }

    /// 记录一次掷骰并判断是否应触发自动评分。
    @discardableResult
    func recordRollAndEvaluateAutoPrompt(source: RollTriggerSource) -> Bool {
        let oldCount = currentRollCount()
        let newCount = oldCount + 1
        userDefaults.set(newCount, forKey: Keys.rollCount)

        let hasPrompted = userDefaults.bool(forKey: Keys.autoPromptedOnce)
        logger.info(
            "[评分流程] 计数更新 source=\(source.rawValue, privacy: .public) old=\(oldCount, privacy: .public) new=\(newCount, privacy: .public) hasPrompted=\(String(hasPrompted), privacy: .public)"
        )

        guard !hasPrompted, newCount >= autoPromptThreshold else {
            logger.info(
                "[评分流程] 自动评分未触发 source=\(source.rawValue, privacy: .public) threshold=\(self.autoPromptThreshold, privacy: .public) count=\(newCount, privacy: .public) hasPrompted=\(String(hasPrompted), privacy: .public)"
            )
            return false
        }

        userDefaults.set(true, forKey: Keys.autoPromptedOnce)
        logger.info(
            "[评分流程] 自动评分触发 source=\(source.rawValue, privacy: .public) threshold=\(self.autoPromptThreshold, privacy: .public) count=\(newCount, privacy: .public)"
        )
        return true
    }
}
