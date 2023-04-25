//
//  Utilities.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/24/23.
//

import CoreData
import Foundation
import SwiftUI

class Utilities {
    static let widgetDefaults = UserDefaults(suiteName: WidgetConstants.suiteName)
    
    static func writeHouseholdsToDefaults(_ households: [String]) {
        if let widgetDefaults {
            widgetDefaults.set(households, forKey: WidgetConstants.WidgetDataTypes.households.rawValue)
        }
    }
    
    static func readHouseholdsFromDefaults() -> [String] {
        if let widgetDefaults {
            let households = widgetDefaults.object(forKey: WidgetConstants.WidgetDataTypes.households.rawValue)
            return households as! [String]
        }
        return []
    }
}
