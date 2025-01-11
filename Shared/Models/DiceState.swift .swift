//
//  DiceState.swift .swift
//  dice
//
//  Created by 郝宜文 on 1/11/25.
//

import SwiftUI

class DiceState: ObservableObject {
    @Published var currentNumber: Int = 1
    @Published var isRolling: Bool = false
    @Published var showResult: Bool = false
    
    func rollDice() {
        isRolling = true
        showResult = false
        
        var randomGenerator = SystemRandomNumberGenerator()
        currentNumber = Int.random(in: 1...6, using: &randomGenerator)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRolling = false
            self.showResult = true
        }
    }
}
