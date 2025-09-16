import SwiftUI

public struct ClippedShapeButtonStyle<S: Shape>: ButtonStyle {
    public let shape: S

    public init(shape: S) {
        self.shape = shape
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? Color.accentColor.opacity(0.1) : Color.clear
            )
            .clipShape(shape)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
