import SwiftUI

@MainActor
public struct CalendarDatePickerToolbarContext: Sendable {
    public let isPresented: Binding<Bool>
    public let label: String
    public let config: CalendarDatePickerToolbarConfiguration
    public let decrementMonth: () -> Void
    public let incrementMonth: () -> Void
}

public struct CalendarDatePickerToolbarConfiguration: Sendable {
    public let buttonSpacing: CGFloat

    public init(
        buttonSpacing: CGFloat = 20
    ) {
        self.buttonSpacing = buttonSpacing
    }
}
