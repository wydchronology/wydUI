import SwiftUI
import Time

public struct CalendarDateCellConfiguration: Sendable {
    let region: Region
    let verticalSpacing: CGFloat
    let alignment: HorizontalAlignment
    let clippedShape: any Shape

    public init(
        region: Region = .autoupdatingCurrent,
        verticalSpacing: CGFloat = 10,
        alignment: HorizontalAlignment = .center,
        clippedShape: some Shape = Circle()
    ) {
        self.region = region
        self.verticalSpacing = verticalSpacing
        self.alignment = alignment
        self.clippedShape = clippedShape
    }
}
