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

    @ViewBuilder
    private var label: some View {
        if isActive {
            Text(formattedLabel)
        } else {
            Text(formattedLabel)
                .foregroundStyle(labelColor ?? Color.primary)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                label
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .rotationEffect(isActive ? .degrees(90) : .degrees(0))
                    .frame(width: iconSize, height: iconSize)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }
}
