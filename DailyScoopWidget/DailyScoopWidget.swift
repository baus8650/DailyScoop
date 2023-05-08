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
        return SimpleEntry(date: Date(), configuration: PetsIntent(), pet: WidgetConstants.widgetPet)
    }

    func getSnapshot(for configuration: PetsIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, pet: WidgetConstants.widgetPet)
        
        completion(entry)
    }

    func getTimeline(for configuration: PetsIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        let pet = WidgetUtilities.fetch(configuration.pet?.name ?? "", from: configuration.pet?.household ?? "")
        let eliminations = WidgetUtilities.fetchEliminations(for: pet)
        let currentDate = Date()
        let nextCheck = Calendar.current.date(byAdding: DateComponents(minute: 5), to: currentDate)
        if let pet {
            let widgetPet = WidgetPet(id: pet.objectID.uriRepresentation().absoluteString, name: pet.name!, birthday: pet.birthday!, weight: pet.weight, eliminations: eliminations.map { WidgetElimination(date: $0.time!, type: $0.type, wasAccident: $0.wasAccident)})
            let entry = SimpleEntry(date: nextCheck!, configuration: configuration, pet: widgetPet)
            
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        } else {
            let entry = SimpleEntry(date: nextCheck!, configuration: configuration, pet: nil)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: PetsIntent
    let pet: WidgetPet?
//    let eliminations: [Elimination]
}

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: PetsIntent
    let pet: WidgetPet
    let eliminations: [WidgetElimination]
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
        case .accessoryRectangular:
            LockScreenRectangularWidget(entry: entry)
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
        .configurationDisplayName("Daily Scoop")
        .description("View your pet's elimination data right on your home or lock screen!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
        
    }
}

struct DailyScoopWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyScoopWidgetView(entry: SimpleEntry(date: Date(), configuration: PetsIntent(), pet: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
