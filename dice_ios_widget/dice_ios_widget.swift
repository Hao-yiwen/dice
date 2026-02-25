//
//  dice_ios_widget.swift
//  dice_ios_widget
//
//  Created by 郝宜文 on 1/11/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct dice_ios_widgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // 背景
            Color(UIColor.systemBackground)
            
            // 卡片阴影和边框效果
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    colorScheme == .dark ?
                        Color(UIColor.systemGray6) :
                        Color.white
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            
            // 主要内容
            VStack(alignment: .leading, spacing: 0) {
                // 左上方骰子图标
                Image(systemName: "die.face.3")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        colorScheme == .dark ?
                            Color.white.opacity(0.9) :
                            Color.black.opacity(0.9)
                    )
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
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            
            // 更清晰的边框
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark ?
                        Color.white.opacity(0.12) :
                        Color.black.opacity(0.06),
                    lineWidth: 1
                )
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
                    Color(UIColor.systemBackground)
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
