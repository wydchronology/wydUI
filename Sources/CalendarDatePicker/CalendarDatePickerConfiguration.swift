import SwiftUI
import Time

@MainActor
public struct CalendarDatePickerConfiguration: Sendable {
    let region: Region
    let components: CalendarDatePickerComponents
    let verticalSpacing: CGFloat
    let horizontalPadding: CGFloat
    let cellSize: CGFloat

    public init(
        region: Region = .autoupdatingCurrent,
        components: CalendarDatePickerComponents = .init(),
        verticalSpacing: CGFloat = 10,
        horizontalPadding: CGFloat = 10,
        cellSize: CGFloat = 42,
    ) {
        self.region = region
        self.components = components
        self.verticalSpacing = verticalSpacing
        self.horizontalPadding = horizontalPadding
        self.cellSize = cellSize
    }
}
