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
    var eliminations: [WidgetElimination]
    var picture: Data?
}

struct WidgetElimination: Identifiable {
    var id = UUID()
    var date: Date
    var type: Int16
    var wasAccident: Bool
}

enum WidgetEliminationType {
    case pee, poop, accident
}
