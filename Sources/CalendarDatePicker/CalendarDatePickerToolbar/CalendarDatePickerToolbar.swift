import SwiftUI
import Time

public struct CalendarDatePickerToolbar: View {
    public typealias Context = CalendarDatePickerToolbarContext

    @Binding var selection: Fixed<Month>
    @Binding var isPresented: Bool

    private let components: CalendarDatePickerToolbarComponents
    private let config: CalendarDatePickerToolbarConfiguration

    public init(
        isPresented: Binding<Bool>,
        selection: Binding<Fixed<Month>>,
        components: CalendarDatePickerToolbarComponents = .init(),
        config: CalendarDatePickerToolbarConfiguration = .init(),
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
