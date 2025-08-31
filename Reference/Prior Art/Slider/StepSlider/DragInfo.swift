import SwiftUI

extension StepSlider {
    enum DragInfo {
        case inactive
        case active(translation: CGFloat, step: Step, start: CGFloat)

        var translation: CGFloat {
            switch self {
            case .inactive:
                .zero
            case let .active(t, _, _):
                t
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive: false
            case .active: true
            }
        }

        var step: StepSlider.Step {
            switch self {
            case .inactive: StepSlider.Step(label: "", description: "", inactiveImage: "", activeImage: "", value: nil)
            case let .active(_, step, _): step
            }
        }

        var start: CGFloat {
            switch self {
            case .inactive: .zero
            case let .active(_, _, start): start
            }
        }
    }
}
