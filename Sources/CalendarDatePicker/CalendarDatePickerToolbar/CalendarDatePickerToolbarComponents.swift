import SwiftUI

@MainActor
public struct CalendarDatePickerToolbarComponents: Sendable {
    public typealias Context = CalendarDatePickerToolbarContext

    let leading: (Context) -> AnyView
    let trailing: (Context) -> AnyView

    public static let defaultLeading: (Context) -> AnyView = { context in
        AnyView(
            HStack(spacing: 0) {
                CalendarMonthLabel(
                    formattedLabel: context.label,
                    isActive: context.isPresented.wrappedValue,
                    action: {
                        withAnimation(.spring(duration: 0.3)) {
                            context.isPresented.wrappedValue.toggle()
                        }
                    },
                    labelColor: .primary
                )

                Spacer()
                    .frame(maxWidth: .infinity)
            }
        )
    }

    public static let defaultTrailing: (Context) -> AnyView = { context in
        AnyView(
            HStack(spacing: context.config.buttonSpacing) {
                Button(action: context.decrementMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
                Button(action: context.incrementMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        )
    }

    public init(
        @ViewBuilder leading: @escaping (Context) -> some View = Self.defaultLeading,
        @ViewBuilder trailing: @escaping (Context) -> some View = Self.defaultTrailing,
    ) {
        self.leading = { context in
            AnyView(leading(context))
        }
        self.trailing = { context in
            AnyView(trailing(context))
        }
    }
}
