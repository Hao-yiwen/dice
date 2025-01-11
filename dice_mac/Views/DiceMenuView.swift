//
//  DiceMenuView.swift
//  dice
//
//  Created by 郝宜文 on 1/11/25.
//
import SwiftUI
import SceneKit

struct DiceMenuView: View {
    @EnvironmentObject var diceState: DiceState
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 骰子3D显示
            SceneView(
                scene: DiceRenderer.createDiceScene(
                    currentNumber: diceState.currentNumber,
                    isRolling: diceState.isRolling
                ),
                pointOfView: DiceRenderer.createCamera(),
                options: [.autoenablesDefaultLighting]
            )
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 掷骰子按钮
            Button(action: { diceState.rollDice() }) {
                HStack {
                    Image(systemName: "dice")
                    Text("摇一摇")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(diceState.isRolling ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(diceState.isRolling)
            
            // 设置按钮
            HStack {
                Spacer()
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                .popover(isPresented: $showingSettings) {
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        HStack {
                            Image(systemName: "power")
                            Text("退出")
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .frame(width: 260)
    }
}
