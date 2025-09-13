import SwiftUI

struct CalendarMonthLabel: View {
    let formattedLabel: String
    let isActive: Bool
    let action: () -> Void
    let labelColor: Color?
    let iconSize: CGFloat

    init(
        formattedLabel: String,
        isActive: Bool,
        action: @escaping () -> Void,
        labelColor: Color? = nil,
        iconSize: CGFloat = 12
    ) {
        self.formattedLabel = formattedLabel
        self.isActive = isActive
        self.action = action
        self.labelColor = labelColor
        self.iconSize = iconSize
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(formattedLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(labelColor)

                Image(systemName: isActive ? "chevron.down" : "chevron.right")
                    .imageScale(.small)
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .buttonStyle(.borderless)
    }
}
