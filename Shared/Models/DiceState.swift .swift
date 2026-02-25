//
//  DiceState.swift .swift
//  dice
//
//  Created by 郝宜文 on 1/11/25.
//

import SwiftUI

@MainActor
final class DiceState: ObservableObject {
    @Published var currentNumber: Int = 1
    @Published var isRolling: Bool = false
    @Published var showResult: Bool = false
    private var rollResetTask: Task<Void, Never>?
    
    func rollDice() {
        guard !isRolling else { return }

        isRolling = true
        showResult = false
        
        var randomGenerator = SystemRandomNumberGenerator()
        currentNumber = Int.random(in: 1...6, using: &randomGenerator)

        rollResetTask?.cancel()
        rollResetTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            await self?.finishRolling()
        }
    }

    private func finishRolling() {
        isRolling = false
        showResult = true
        rollResetTask = nil
    }

    deinit {
        rollResetTask?.cancel()
    }
}
