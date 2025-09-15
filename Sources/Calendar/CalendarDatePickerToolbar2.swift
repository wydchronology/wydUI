import SwiftUI
import Time

public struct CalendarDatePickerToolbarConfig: Sendable {
    let buttonSpacing: CGFloat

    public init(
        buttonSpacing: CGFloat = 20
    ) {
        self.buttonSpacing = buttonSpacing
    }
}

@MainActor
public struct CalendarDatePickerToolbarContext: Sendable {
    let isPresented: Binding<Bool>
    let label: String
    let config: CalendarDatePickerToolbarConfig
    let decrementMonth: () -> Void
    let incrementMonth: () -> Void
}

@MainActor
public struct CalendarDatePickerToolbarComponents: Sendable {
    public typealias Context = CalendarDatePickerToolbarContext

    let leading: (Context) -> AnyView
    let trailing: (Context) -> AnyView

    static let defaultLeading: (Context) -> AnyView = { context in
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

    static let defaultTrailing: (Context) -> AnyView = { context in
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

    public init() {
        leading = Self.defaultLeading
        trailing = Self.defaultTrailing
    }

    public init(
        @ViewBuilder leading: @escaping (Context) -> some View,
        @ViewBuilder trailing: @escaping (Context) -> some View,
    ) {
        self.leading = { context in
            AnyView(leading(context))
        }
        self.trailing = { context in
            AnyView(trailing(context))
        }
    }

    public init(
        leading: @escaping (Context) -> some View,
    ) {
        self.leading = { context in
            AnyView(leading(context))
        }
        trailing = Self.defaultTrailing
    }

    public init(
        trailing: @escaping (Context) -> some View
    ) {
        leading = Self.defaultLeading
        self.trailing = { context in
            AnyView(trailing(context))
        }
    }
}

public struct CalendarDatePickerToolbar2: View {
    public typealias Context = CalendarDatePickerToolbarContext

    @Binding var selection: Fixed<Month>
    @Binding var isPresented: Bool

    private let components: CalendarDatePickerToolbarComponents
    private let config: CalendarDatePickerToolbarConfig

    public init(
        isPresented: Binding<Bool>,
        selection: Binding<Fixed<Month>>,
        components: CalendarDatePickerToolbarComponents = .init(),
        config: CalendarDatePickerToolbarConfig = .init(),
    ) {
        _isPresented = isPresented
        _selection = selection
        self.config = config
        self.components = components
    }

    private var monthYearLabel: String {
        selection.format(year: .naturalDigits, month: .naturalName)
    }

    private func decrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            selection = selection.previousMonth
        }
    }

    private func incrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            selection = selection.nextMonth
        }
    }

    public var body: some View {
        let context = Context(
            isPresented: $isPresented,
            label: monthYearLabel,
            config: config,
            decrementMonth: decrementMonth,
            incrementMonth: incrementMonth
        )

        HStack(spacing: .zero) {
            components.leading(context)

            if !isPresented {
                components.trailing(context)
            }
        }
    }
}
