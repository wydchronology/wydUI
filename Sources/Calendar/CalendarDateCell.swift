import SwiftUI

struct CalendarDateCell: View {
    var size: CGFloat = 40

    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let calendar = Calendar.current
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded, weight: isSelected ? .heavy : .regular))
                .foregroundColor(isSelected ? Color.accentColor : Color.primary)
                .frame(width: size, height: size)
                .background(isSelected ? Color.accentColor.opacity(0.3) : Color.clear)
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
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}
