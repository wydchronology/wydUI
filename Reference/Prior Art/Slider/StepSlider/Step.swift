import SwiftUI

extension StepSlider {
    struct Step: Identifiable, Equatable, Hashable {
        let id = UUID()
        let label: String
        let description: String
        let inactiveImage: String
        let activeImage: String
        let value: V?
    }
}
