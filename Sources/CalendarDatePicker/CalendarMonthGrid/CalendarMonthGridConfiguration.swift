import SwiftUI
import Time

public struct CalendarMonthGridConfiguration: Sendable {
    let region: Region
    let verticalSpacing: CGFloat

    public init(
        region: Region = .autoupdatingCurrent,
        verticalSpacing: CGFloat = 10
    ) {
        self.region = region
        self.verticalSpacing = verticalSpacing
    }
}
