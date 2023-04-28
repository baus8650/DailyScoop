//
//  PeeView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/27/23.
//

import SwiftUI

struct PeeView: View {
    @State var isAnimating: Bool = false
    var body: some View {
        VStack {
            Image("pee")
                .scaleEffect(x: isAnimating ? 1 : 0.3, y: isAnimating ? 1 : 2)
                .offset(x: 0, y: isAnimating ? 0 : -150)
                .animation(.spring(response: 0.7, dampingFraction: 0.65))
            Text("Good job!")
                .font(.headline)
//                .padding(.bottom, 8) 
        }
        .frame(width: 180, height: 144)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 1.0)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct PeeView_Previews: PreviewProvider {
    static var previews: some View {
        PeeView()
    }
}
