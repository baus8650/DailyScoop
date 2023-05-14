//
//  Constants.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/24/23.
//

import Foundation
import UIKit

final class WidgetConstants {
    static let suiteName: String = "group.timbausch.com.DailyScoopWidget"
    
    enum WidgetDataTypes: String {
        case households = "households"
    }
    
    static let startOfDay = Calendar.current.startOfDay(for: Date())
    
    static var image = UIImage(named: "penny")!
    static var rotatedImage = image.rotateImage()!
    static let imageData = rotatedImage.jpegData(compressionQuality: 1.0)
    static let widgetPet = WidgetPet(
        id: "x-coredata://EB8922D9-DC06-4256-A21B-DFFD47D7E6DA/MyEntity/p3",
        name: "Penny",
        birthday: Date(),
        weight: 27.5,
        eliminations: [
            WidgetElimination(
                date: Calendar.current.date(byAdding: DateComponents(hour: 8, minute: 27), to: startOfDay)!,
                type: 1,
                wasAccident: false),
            WidgetElimination(
                date: Calendar.current.date(byAdding: DateComponents(hour: 12, minute: 48), to: startOfDay)!,
                type: 1,
                wasAccident: false),
            WidgetElimination(
                date: Calendar.current.date(byAdding: DateComponents(hour: 18, minute: 7), to: startOfDay)!,
                type: 1,
                wasAccident: false),
            WidgetElimination(
                date: Calendar.current.date(byAdding: DateComponents(hour: 8, minute: 31), to: startOfDay)!,
                type: 2,
                wasAccident: false),
            WidgetElimination(
                date: Calendar.current.date(byAdding: DateComponents(hour: 18, minute: 9), to: startOfDay)!,
                type: 2,
                wasAccident: false)
        ],
        picture: imageData)
}
