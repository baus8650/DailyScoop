//
//  AccidentView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/27/23.
//

import SwiftUI

struct AccidentView: View {
    @State var isHidden: Bool = false
    var body: some View {
        VStack {
            ZStack {
                Image("accident")
                Text("**!**")
                    .offset(x: 0, y: 2)
                    .font(.largeTitle)
                    .scaleEffect(1.4)
                    .foregroundColor(isHidden ? Color(red: 228/255, green: 133/255, blue: 133/255) : .white.opacity(0.85))
            }
            Text("Oh no!")
                .font(.headline)
        }
        .frame(width: 180, height: 144)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHidden.toggle()
                }
            }
        }
    }
}

struct AccidentView_Previews: PreviewProvider {
    static var previews: some View {
        AccidentView()
    }
}
