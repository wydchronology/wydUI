import SwiftUI
import Time

@MainActor
public struct CalendarDateCellComponents: Sendable {
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

