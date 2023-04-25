//
//  File.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/24/23.
//

import Foundation

struct WidgetPet {
    var id: String
    var name: String
    var birthday: Date
    var weight: Double
    var peeEntries: [WidgetElimination]
    var poopEntries: [WidgetElimination]
    var accidentEntries: [WidgetElimination]
}

struct WidgetElimination {
    var date: Date
    var type: WidgetEliminationType
}

enum WidgetEliminationType {
    case pee, poop, accident
}
