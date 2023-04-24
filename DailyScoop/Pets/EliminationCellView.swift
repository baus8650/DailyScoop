//
//  EliminationCellView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import SwiftUI

struct EliminationCellView: View {
    @ObservedObject var elimination: Elimination
    var stack = CoreDataStack.shared
    var body: some View {
        if elimination.type == 1 {
            HStack {
                VStack(alignment: .leading) {
                    Text("Peed")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(elimination.wasAccident ? .red : .yellow)
                    Text("\(formatter(for: elimination.time ?? Date()))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if elimination.wasAccident {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
        } else {
            HStack {
                VStack(alignment: .leading) {
                    Text("Pooped")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(elimination.wasAccident ? .red : .brown)
                    Text("\(formatter(for: elimination.time ?? Date()))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if elimination.wasAccident {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formatter(for date: Date, with timeShowing: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if timeShowing {
            formatter.timeStyle = .short
        } else {
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: date)
    }
}

