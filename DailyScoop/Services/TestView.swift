//
//  TestView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/3/23.
//

import SwiftUI

struct TestView: View {
    @State var pets = [WidgetPet]()
    
    var body: some View {
        ForEach(pets, id: \.name) { pet in
            Text("\(pet.name)")
        }
//        .onAppear {
//            self.pets = WidgetUtilities.fetch(from: "New House")
//            WidgetUtilities.newFetch(from: "New House")
//        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
