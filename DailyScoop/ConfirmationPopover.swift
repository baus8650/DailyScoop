//
//  ConfirmationPopover.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/27/23.
//

import SwiftUI

struct ConfirmationPopover: View {
    var eliminationType: EliminationType
    
    init(for eliminationType: EliminationType) {
        self.eliminationType = eliminationType
    }
    
    var body: some View {
        switch eliminationType {
        case .none:
            AccidentView()
                .clipped()
                .background(
                    .regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        case .liquid:
            PeeView()
                .clipped()
                .background(
                    .regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        case .solid:
            PoopView()
                .clipped()
                .background(
                    .regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
    }
}

struct ConfirmationPopover_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationPopover(for: .solid)
    }
}
