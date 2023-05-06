//
//  DailyScoopWidget.swift
//  DailyScoopWidget
//
//  Created by Tim Bausch on 4/24/23.
//

import CoreData
import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: [])
    }

    func getSnapshot(for configuration: PetsIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, pet: nil, eliminations: [])
        completion(entry)
    }

    func getTimeline(for configuration: PetsIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
//        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let pet = WidgetUtilities.fetch(from: configuration.household?.name ?? "")
//        }
//        try? CoreDataStack.shared.context.setQueryGenerationFrom(.current)
//        try? CoreDataStack.shared.context.setQueryGenerationFrom(.current)
//        CoreDataStack.shared.context.refreshAllObjects()

        let pet = WidgetUtilities.fetch(configuration.pet?.name ?? "", from: configuration.pet?.household ?? "")
        let eliminations = WidgetUtilities.fetchEliminations(for: pet)
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, configuration: configuration, pet: pet, eliminations: eliminations)
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration, pet: pet, eliminations: eliminations)
//            entries.append(entry)
//        }
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: PetsIntent
    let pet: Pet?
    let eliminations: [Elimination]
}

//struct DailyScoopWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        if let pet = entry.pet {
//            Text(pet.name!)
//        }
//    }
//}

struct DailyScoopWidgetView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(entry: entry)
        case .systemMedium:
            MediumWidget(entry: entry)
        case .systemLarge:
            LargeWidget(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct DailyScoopWidget: Widget {
    let kind: String = "DailyScoopWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: PetsIntent.self, provider: Provider()) { entry in
            DailyScoopWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DailyScoopWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyScoopWidgetView(entry: SimpleEntry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
