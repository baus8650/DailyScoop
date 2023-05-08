//
//  Clipboard.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/7/23.
//

import SwiftUI
import WidgetKit

struct WidgetBackground: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [Color("darkPurple"), Color("lightPurple")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("buttonBackground"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                Image("clipboard")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .padding(.top, 2)
        }
    }
}

struct WidgetBackground_Previews: PreviewProvider {
    static var previews: some View {
        WidgetBackground()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
