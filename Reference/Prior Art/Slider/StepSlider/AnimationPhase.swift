import SwiftUI

extension StepSlider {
    enum AnimationPhase: CaseIterable {
        case initial
        case move
        case scale

        var verticalOffset: Double {
            switch self {
            case .initial: 0
            case .move, .scale: -7.5
            }
        }

        var scaleEffect: Double {
            switch self {
            case .initial: 1
            case .move, .scale: 1.1
            }
        }
    }
}
