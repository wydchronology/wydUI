import SwiftUI

struct CalendarDatePicker: View {
    @State private var selectedDate: Date = .init()
    @State private var currentMonth: Date = .init()
    @State private var isMonthYearPickerPresented: Bool = false

    private let navigationHeaderBuilder: (Binding<Date>, Binding<Bool>) -> AnyView
    private let monthYearPickerBuilder: (Binding<Date>, Binding<Bool>) -> AnyView

    let spacing: CGFloat

    init(
        navigationHeaderBuilder: @escaping (Binding<Date>, Binding<Bool>) -> AnyView = { currentMonthBinding, isPickerPresentedBinding in
            AnyView(
                CalendarMonthNavigationHeader(
                    month: currentMonthBinding,
                    isMonthYearPickerPresented: isPickerPresentedBinding
                )
            )
        },
        monthYearPickerBuilder: @escaping (Binding<Date>, Binding<Bool>) -> AnyView = { monthBinding, isPresentedBinding in
            AnyView(
                CalendarMonthYearPicker(
                    month: monthBinding,
                    isPresented: isPresentedBinding
                )
            )
        },
        spacing: CGFloat = 10
    ) {
        self.navigationHeaderBuilder = navigationHeaderBuilder
        self.monthYearPickerBuilder = monthYearPickerBuilder
        self.spacing = spacing
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: spacing) {
                navigationHeaderBuilder($currentMonth, $isMonthYearPickerPresented)
                
                if isMonthYearPickerPresented {
                    monthYearPickerBuilder($currentMonth, $isMonthYearPickerPresented)
                        .frame(maxWidth: .infinity)
                        .frame(height: proxy.size.height)
                } else {
                    // Placeholder for calendar grid (to be implemented)
                    Rectangle()
                        .fill(Color.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: proxy.size.height)
                }
            }
        }
    }
}

#Preview {
    CalendarDatePicker()
        .frame(height: 300)
        .padding()
}
