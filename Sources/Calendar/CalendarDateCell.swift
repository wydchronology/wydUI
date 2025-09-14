import SwiftUI

struct CalendarDateCell: View {
    let calendar: Calendar

    let date: Date
    let selection: Date
    let foregroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let backgroundColor: (_ isSelected: Bool, _ isToday: Bool) -> Color
    let action: () -> Void

    init(
        calendar: Calendar = .autoupdatingCurrent,
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
        action: @escaping () -> Void,
    ) {
        self.calendar = calendar
        self.date = date
        self.selection = selection
        self.action = action
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
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

    var body: some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.system(.body, design: .rounded, weight: isSelected ? .bold : .regular))
                .foregroundColor(foregroundColor(isSelected, isToday))
                .background(backgroundColor(isSelected, isToday))
                .clipShape(Circle())
        }
        .buttonStyle(PressedButtonStyle())
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
