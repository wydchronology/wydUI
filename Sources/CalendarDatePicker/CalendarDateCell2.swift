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

@MainActor
public struct CalendarDateCell2Components: Sendable {
    let label: (_ label: Fixed<Day>, _ isSelected: Bool, _ isToday: Bool, _ context: CalendarDateCellConfiguration) -> AnyView
    let indicator: (Fixed<Day>, CalendarDateCellConfiguration) -> AnyView

    static let defaultIndicator: (Fixed<Day>, CalendarDateCellConfiguration) -> AnyView = { _, _ in
        AnyView(
            EmptyView()
        )
    }

    static let defaultLabel: (Fixed<Day>, Bool, Bool, CalendarDateCellConfiguration) -> AnyView = { day, isSelected, isToday, context in
        let text = "\(day.format(day: .naturalDigits))"
        return AnyView(
            Text(text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.system(.title3, design: .rounded, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? (isToday ? Color(UIColor.white) : Color.accentColor) : (isToday ? Color.accentColor : Color(UIColor.label)))
                .background(isSelected ? (isToday ? Color.accentColor : Color.accentColor.opacity(0.1)) : Color.clear)
                .clipShape(AnyShape(context.clippedShape))
        )
    }

    public init() {
        label = Self.defaultLabel
        indicator = Self.defaultIndicator
    }

    public init(
        @ViewBuilder label: @escaping (Fixed<Day>, Bool, Bool, CalendarDateCellConfiguration) -> some View
    ) {
        self.label = { day, isSelected, isToday, context in
            AnyView(label(day, isSelected, isToday, context))
        }
        indicator = Self.defaultIndicator
    }

    public init(
        @ViewBuilder indicator: @escaping (Fixed<Day>, CalendarDateCellConfiguration) -> some View
    ) {
        label = Self.defaultLabel
        self.indicator = { day, context in
            AnyView(indicator(day, context))
        }
    }

    public init(
        @ViewBuilder label: @escaping (Fixed<Day>, Bool, Bool, CalendarDateCellConfiguration) -> some View,
        @ViewBuilder indicator: @escaping (Fixed<Day>, CalendarDateCellConfiguration) -> some View
    ) {
        self.label = { day, isSelected, isToday, context in
            AnyView(label(day, isSelected, isToday, context))
        }
        self.indicator = { day, context in
            AnyView(indicator(day, context))
        }
    }
}

public struct CalendarDateCell2: View {
    let selection: Date
    let day: Fixed<Day>?
    let config: CalendarDateCellConfiguration
    let components: CalendarDateCell2Components
    let action: (Fixed<Day>) -> Void

    public init(
        selection: Date,
        day: Fixed<Day>?,
        components: CalendarDateCell2Components = .init(),
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
