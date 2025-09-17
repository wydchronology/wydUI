import SwiftUI
import Time

@MainActor
public struct CalendarMonthGridComponents: Sendable {
    let cell: (Fixed<Day>?) -> AnyView

    public init(
        @ViewBuilder cell: @escaping (Fixed<Day>?) -> some View
    ) {
        self.cell = { day in
            AnyView(cell(day))
        }
    }
}
