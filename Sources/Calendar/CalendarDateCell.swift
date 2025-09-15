import SwiftUI

public struct CalendarDateCellLabel: View {
    let dayString: String
    let isSelected: Bool
    let isToday: Bool
    let size: CGFloat

    public init(dayString: String, isSelected: Bool, isToday: Bool, size: CGFloat) {
        self.dayString = dayString
        self.isSelected = isSelected
        self.isToday = isToday
        self.size = size
    }

    public var body: some View {
        Text(dayString)
            .frame(width: size, height: size)
            .font(.system(.title3, design: .rounded, weight: isSelected ? .bold : .regular))
            .foregroundColor(isSelected ? (isToday ? Color(UIColor.white) : Color.accentColor) : (isToday ? Color.accentColor : Color(UIColor.label)))
            .background(isSelected ? (isToday ? Color.accentColor : Color.accentColor.opacity(0.1)) : Color.clear)
            .clipShape(Circle())
    }
}

public struct CalendarDateCell<Indicator: View, Label: View>: View {
    let calendar: Calendar
    let size: CGFloat
    let spacing: CGFloat
    let date: Date
    let selection: Date
    let label: (String, Bool, Bool, CGFloat) -> Label
    let foregroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let backgroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let indicator: (Date) -> Indicator
    let action: () -> Void

    public init(
        calendar: Calendar = .autoupdatingCurrent,
        size: CGFloat = 42,
        spacing: CGFloat = 5,
        date: Date,
        selection: Date,
        foregroundColor: @escaping (Bool, Bool) -> Color = { isSelected, isToday in
            if isSelected {
                return isToday ? Color(UIColor.white) : Color.accentColor
            } else if isToday {
                return Color.accentColor
            } else {
                return Color(UIColor.label)
            }
        },
        backgroundColor: @escaping (Bool, Bool) -> Color = { isSelected, isToday in
            if isSelected {
                return isToday ? Color.accentColor : Color.accentColor.opacity(0.1)
            }
            return Color.clear
        },
        @ViewBuilder label: @escaping (String, Bool, Bool, CGFloat) -> Label = {
            CalendarDateCellLabel(dayString: $0, isSelected: $1, isToday: $2, size: $3)
        },
        @ViewBuilder indicator: @escaping (Date) -> Indicator = { _ in
            EmptyView()
        },
        action: @escaping () -> Void,
    ) {
        self.calendar = calendar
        self.size = size
        self.spacing = spacing
        self.date = date
        self.selection = selection
        self.label = label
        self.action = action
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.indicator = indicator
    }

    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selection)
    }

    private var isToday: Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }

    public var body: some View {
        VStack(spacing: spacing) {
            Button(action: action) {
                label(
                    "\(calendar.component(.day, from: date))",
                    isSelected,
                    isToday,
                    size
                )
            }

            indicator(date)

            Spacer()
        }
    }
}
