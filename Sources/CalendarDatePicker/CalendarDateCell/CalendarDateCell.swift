import SwiftUI
import Time

public struct CalendarDateCell: View {
    let selection: Date
    let day: Fixed<Day>?
    let config: CalendarDateCellConfiguration
    let components: CalendarDateCellComponents
    let action: (Fixed<Day>) -> Void

    public init(
        selection: Date,
        day: Fixed<Day>?,
        components: CalendarDateCellComponents = .init(),
        config: CalendarDateCellConfiguration = .init(),
        action: @escaping (Fixed<Day>) -> Void
    ) {
        self.selection = selection
        self.day = day
        self.components = components
        self.config = config
        self.action = action
    }

    private var isSelected: Bool {
        guard let day = day else { return false }
        let selectedDate = Fixed<Day>(region: config.region, date: selection)
        return day.overlaps(selectedDate)
    }

    private var isToday: Bool {
        guard let day = day else { return false }
        let today = Fixed<Day>(region: config.region, date: Date())
        return today.overlaps(day)
    }

    public var body: some View {
        if let day = day {
            VStack(alignment: config.alignment, spacing: config.verticalSpacing) {
                Button(action: {
                    action(day)
                }) {
                    components.label(day, isSelected, isToday, config)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                components.indicator(day, config)
            }
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
