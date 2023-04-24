//
//  Constants.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import Foundation

public enum Gender: Int16, CaseIterable, Identifiable {
    case female = 0
    case male = 1
    public var id: Self { self }
    
    var description: String {
        switch self {
        case .female:
            return "Female"
        case .male:
            return "Male"
        }
    }
}

public enum EliminationType: Int16, CaseIterable, Identifiable {
    case none = 0
    case liquid = 1
    case solid = 2
    public var id: Self { self }
    
    var description: String {
        switch self {
        case .none:
            return "No Type Recorded"
        case .liquid:
            return "Pee"
        case .solid:
            return "Poop"
        }
    }
}

public enum Consistency: Int16, CaseIterable, Identifiable {
    case none = 0
    case liquid = 1
    case mostlyLiquid = 2
    case mushy = 3
    case firm = 4
    case solid = 5
    public var id: Self { self }
    
    var description: String {
        switch self {
        case .none:
            return "No Consistency Recorded"
        case .liquid:
            return "Liquid"
        case .mostlyLiquid:
            return "Mostly Liquid"
        case .mushy:
            return "Mushy"
        case .firm:
            return "Firm"
        case .solid:
            return "Solid"
        }
    }
}

public enum SampleSize: String, CaseIterable {
    case day = "D"
    case week = "W"
    case month = "M"
    case sixMonths = "6M"
    case year = "Y"
}

public enum GraphType: String, CaseIterable {
    case bar = "Bar"
    case line = "Line"
}
