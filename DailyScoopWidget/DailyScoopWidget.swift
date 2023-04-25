//
//  DailyScoopWidget.swift
//  DailyScoopWidget
//
//  Created by Tim Bausch on 4/24/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: HouseholdsIntent())
    }

    func getSnapshot(for configuration: HouseholdsIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: HouseholdsIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: HouseholdsIntent
}

struct DailyScoopWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct DailyScoopWidget: Widget {
    let kind: String = "DailyScoopWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HouseholdsIntent.self, provider: Provider()) { entry in
            DailyScoopWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([])
    }
}

struct DailyScoopWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyScoopWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: HouseholdsIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
