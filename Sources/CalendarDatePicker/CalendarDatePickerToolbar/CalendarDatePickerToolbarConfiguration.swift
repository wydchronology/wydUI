import SwiftUI

@MainActor
public struct CalendarDatePickerToolbarContext: Sendable {
    let isPresented: Binding<Bool>
    let label: String
    let config: CalendarDatePickerToolbarConfiguration
    let decrementMonth: () -> Void
    let incrementMonth: () -> Void
}

public struct CalendarDatePickerToolbarConfiguration: Sendable {
    let buttonSpacing: CGFloat

    public init(
        buttonSpacing: CGFloat = 20
    ) {
        self.buttonSpacing = buttonSpacing
    }
}
