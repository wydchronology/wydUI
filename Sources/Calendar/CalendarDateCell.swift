import SwiftUI

public struct CalendarDateCell<Indicator: View>: View {
    let calendar: Calendar
    let size: CGFloat
    let spacing: CGFloat
    let date: Date
    let selection: Date
    let foregroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let backgroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let indicator: (Date) -> Indicator
    let action: () -> Void

    public init(
        calendar: Calendar = .autoupdatingCurrent,
        size: CGFloat = 40,
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

    private var label: String {
        "\(calendar.component(.day, from: date))"
    }

    public var body: some View {
        VStack(spacing: spacing) {
            Button(action: action) {
                Text(label)
                    .frame(width: size, height: size)
                    .font(.system(.body, design: .rounded, weight: isSelected ? .bold : .regular))
                    .foregroundColor(foregroundColor(isSelected, isToday))
                    .background(backgroundColor(isSelected, isToday))
                    .clipShape(Circle())
            }
            .buttonStyle(PressedButtonStyle())

            indicator(date)

           Spacer()
        }
    }

    struct PressedButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(
                    configuration.isPressed ? Color.accentColor.opacity(0.1) : Color.clear
                )
                .clipShape(Circle())
                .animation(.spring(duration: 0.2), value: configuration.isPressed)
        }
    }
}
