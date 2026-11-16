//
//  dice_ios_widget.swift
//  dice_ios_widget
//
//  Created by 郝宜文 on 1/11/25.
//

import WidgetKit
import SwiftUI
import UIKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func snapshot(in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func timeline(in context: Context) async -> Timeline<SimpleEntry> {
        Timeline(entries: [SimpleEntry(date: Date())], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct dice_ios_widgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // 卡片跟随系统分组背景，深浅色由 UIColor 动态色负责
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            
            // 主要内容
            VStack(alignment: .leading, spacing: 0) {
                // 左上方骰子图标
                Image(systemName: "die.face.3")
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.primary)
                    .font(.system(size: 32, weight: .medium))
                    .padding(.leading, 16)
                    .padding(.top, 16)
                
                Spacer()
                
                // 底部文字按钮
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 13))
                    Text(L10n.text("action.roll"))
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.9),
                                    Color.blue.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .widgetURL(URL(string: "diceapp://roll"))
    }
}

struct dice_ios_widget: Widget {
    let kind: String = "dice_ios_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            dice_ios_widgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(uiColor: .systemBackground)
                }
        }
        .configurationDisplayName(L10n.text("widget.display_name"))
        .description(L10n.text("widget.description"))
        .supportedFamilies([.systemSmall])
    }
}

@main
struct MainBundle: WidgetBundle {
    var body: some Widget {
        dice_ios_widget()
    }
}
