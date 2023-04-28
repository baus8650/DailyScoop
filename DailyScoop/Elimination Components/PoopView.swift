//
//  PoopView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/27/23.
//

import SwiftUI

struct PoopView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack() {
            Image("poop4")
                .offset(y: isAnimating ? 40 : -300)
                .animation(.linear(duration: 0.55).delay(0.18))
            Image("poop3")
                .offset(y: isAnimating ? 27 : -300)
                .animation(.linear(duration: 0.46).delay(0.14))
            Image("poop2")
                .offset(y: isAnimating ? 13 : -300)
                .animation(.linear(duration: 0.4).delay(0.05))
            Image("poop1")
                .offset(y: isAnimating ? 0 : -300)
                .animation(.linear(duration: 0.3))
            Text("Good job!")
                .font(.headline)
                .padding(.bottom, 24)
        }
        .frame(width: 180, height: 144)
        .onAppear {
            isAnimating = true
        }
    }
}

struct PoopView_Previews: PreviewProvider {
    static var previews: some View {
        PoopView()
    }
}

struct RoundedTriangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // Define the points of the triangle
        let point1 = CGPoint(x: 0, y: height)
        let point2 = CGPoint(x: width / 2, y: 0)
        let point3 = CGPoint(x: width, y: height)
        
        // Define the control points for the rounded corners
        let control1 = CGPoint(x: cornerRadius, y: height)
        let control2 = CGPoint(x: width / 2, y: cornerRadius)
        let control3 = CGPoint(x: width - cornerRadius, y: height)
        
        // Create the path
        path.move(to: point1)
        path.addQuadCurve(to: point2, control: control1)
        path.addQuadCurve(to: point3, control: control2)
        path.addQuadCurve(to: point1, control: control3)
        path.closeSubpath()
        
        return path
    }
}
