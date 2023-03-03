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
    var typeInt: Int16
    var wasAccident: Bool = false
    var body: some View {
        if typeInt == 1 {
            HStack {
//                Spacer()
                VStack(alignment: .leading) {
                    Text("Peed")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(wasAccident ? .red : .yellow)
                    Text("\(formatter(for: elimination.time!))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 16) {
                    if wasAccident {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.yellow)
                    }
                    Button {
                        stack.delete(elimination)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.yellow)
                    }
                }
//                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .background(.gray)
                    .opacity(0.05)
            )
        } else {
            HStack {
//                Spacer()
                VStack(alignment: .leading) {
                    Text("Pooped")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(wasAccident ? .red : .brown)
                    Text("\(formatter(for: elimination.time!))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 16) {
                    if wasAccident {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.brown)
                    }
                    Button {
                        stack.delete(elimination)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.brown)
                    }
                }
//                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .background(.gray)
                    .opacity(0.05)
            )
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

