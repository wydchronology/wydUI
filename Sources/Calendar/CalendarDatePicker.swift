import SwiftUI

struct CalendarDatePicker: View {
    @State private var selectedDate: Date = .init()
    @State private var currentMonth: Date = .init()
    @State private var isMonthYearPickerPresented: Bool = false

    private let navigationHeaderBuilder: (Binding<Date>, Binding<Bool>) -> AnyView

    init(
        navigationHeaderBuilder: @escaping (Binding<Date>, Binding<Bool>) -> AnyView = { currentMonthBinding, isPickerPresentedBinding in
            AnyView(
                CalendarMonthNavigationHeader(
                    month: currentMonthBinding,
                    isMonthYearPickerPresented: isPickerPresentedBinding
                )
            )
        }
    ) {
        self.navigationHeaderBuilder = navigationHeaderBuilder
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationHeaderBuilder($currentMonth, $isMonthYearPickerPresented)

            // Placeholder for calendar grid (to be implemented)
            Rectangle()
                .fill(Color.red)
                .frame(height: 200)
        }
    }
}
