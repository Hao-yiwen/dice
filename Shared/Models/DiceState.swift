//
//  DiceState.swift
//  dice
//
//  Created by 郝宜文 on 1/11/25.
//

import SwiftUI
import OSLog

@MainActor
final class DiceState: ObservableObject {
    @Published var currentNumber: Int
    @Published var isRolling: Bool
    @Published var showResult: Bool
    @Published var visibleFaceRotationQuarterTurns: Int
    private var rollResetTask: Task<Void, Never>?
    private let logger: Logger

    init() {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.yiwen.dice",
            category: "掷骰状态"
        )
        currentNumber = Self.generateRandomNumber()
        isRolling = false
        showResult = true
        visibleFaceRotationQuarterTurns = Self.generateRandomQuarterTurns()

        logger.info(
            "[掷骰] 初始化完成 currentNumber=\(self.currentNumber, privacy: .public) visibleFaceRotationQuarterTurns=\(self.visibleFaceRotationQuarterTurns, privacy: .public)"
        )
    }
    
    func rollDice() {
        logger.info(
            "[掷骰] 收到掷骰请求 currentNumber=\(self.currentNumber, privacy: .public) isRolling=\(String(self.isRolling), privacy: .public)"
        )

        guard !isRolling else {
            logger.info("[掷骰] 忽略掷骰请求 reason=骰子仍在滚动")
            return
        }

        isRolling = true
        showResult = false

        let previousNumber = currentNumber
        let previousQuarterTurns = visibleFaceRotationQuarterTurns
        currentNumber = Self.generateRandomNumber()
        visibleFaceRotationQuarterTurns = Self.generateRandomQuarterTurns()
        logger.info(
            "[掷骰] 已生成随机结果 previous=\(previousNumber, privacy: .public) current=\(self.currentNumber, privacy: .public) previousQuarterTurns=\(previousQuarterTurns, privacy: .public) currentQuarterTurns=\(self.visibleFaceRotationQuarterTurns, privacy: .public)"
        )

        if rollResetTask != nil {
            logger.info("[掷骰] 发现未结束的滚动任务，准备取消旧任务")
        }
        rollResetTask?.cancel()
        rollResetTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                self?.handleRollResetCancellation(reason: "休眠被打断")
                return
            }

            guard !Task.isCancelled else {
                self?.handleRollResetCancellation(reason: "任务被取消")
                return
            }
            self?.finishRolling()
        }
    }

    private func finishRolling() {
        isRolling = false
        showResult = true
        rollResetTask = nil
        logger.info(
            "[掷骰] 滚动结束 currentNumber=\(self.currentNumber, privacy: .public) showResult=\(String(self.showResult), privacy: .public) visibleFaceRotationQuarterTurns=\(self.visibleFaceRotationQuarterTurns, privacy: .public)"
        )
    }

    private func handleRollResetCancellation(reason: String) {
        rollResetTask = nil
        logger.info("[掷骰] 结束任务提前退出 reason=\(reason, privacy: .public)")
    }

    private static func generateRandomNumber() -> Int {
        var randomGenerator = SystemRandomNumberGenerator()
        return Int.random(in: 1...6, using: &randomGenerator)
    }

    private static func generateRandomQuarterTurns() -> Int {
        var randomGenerator = SystemRandomNumberGenerator()
        return Int.random(in: 0...3, using: &randomGenerator)
    }

    deinit {
        rollResetTask?.cancel()
    }
}
