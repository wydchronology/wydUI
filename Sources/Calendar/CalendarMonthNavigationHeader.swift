import SwiftUI

struct CalendarMonthNavigationHeader: View {
    @Binding var month: Date
    @Binding var isMonthYearPickerPresented: Bool
    let monthLabelBuilder: (Date, String, Binding<Bool>) -> AnyView
    let previousButtonBuilder: (@escaping () -> Void) -> AnyView
    let nextButtonBuilder: (@escaping () -> Void) -> AnyView

    var buttonSpacing: CGFloat = 20

    init(
        month: Binding<Date>,
        isMonthYearPickerPresented: Binding<Bool> = .constant(false),
        monthLabelBuilder: @escaping (Date, String, Binding<Bool>) -> AnyView = { _, formattedLabel, isPresentedBinding in
            AnyView(
                CalendarMonthLabel(
                    formattedLabel: formattedLabel,
                    isActive: isPresentedBinding.wrappedValue,
                    action: {
                        withAnimation(.interactiveSpring(duration: 0.3)) {
                            isPresentedBinding.wrappedValue.toggle()
                        }
                    },
                    labelColor: .primary
                )
            )
        },
        previousButtonBuilder: @escaping (@escaping () -> Void) -> AnyView = { action in
            AnyView(
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
            )
        },
        nextButtonBuilder: @escaping (@escaping () -> Void) -> AnyView = { action in
            AnyView(
                Button(action: action) {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
            )
        }
    ) {
        _month = month
        _isMonthYearPickerPresented = isMonthYearPickerPresented
        self.monthLabelBuilder = monthLabelBuilder
        self.previousButtonBuilder = previousButtonBuilder
        self.nextButtonBuilder = nextButtonBuilder
    }

    private var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    private func incrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
        }
    }

    private func decrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
        }
    }

    var body: some View {
        HStack(spacing: .zero) {
            monthLabelBuilder(month, monthYearLabel, $isMonthYearPickerPresented)

            Spacer()

            HStack(spacing: buttonSpacing) {
                previousButtonBuilder(decrementMonth)
                nextButtonBuilder(incrementMonth)
            }
        }
    }
}

#Preview {
    @Previewable @State var previewMonth = Date()
    @Previewable @State var isPickerPresented = false

    VStack(spacing: 20) {
        // Test different styling approaches
        Text("Testing CalendarMonthLabel with labelColor:")
            .font(.headline)

        // Default styling
        CalendarMonthLabel(
            formattedLabel: previewMonth.formatted(.dateTime.month(.wide).year()),
            isActive: isPickerPresented,
            action: { isPickerPresented.toggle() }
        )

        // With custom label color
        CalendarMonthLabel(
            formattedLabel: previewMonth.formatted(.dateTime.month(.wide).year()),
            isActive: isPickerPresented,
            action: { isPickerPresented.toggle() },
            labelColor: .blue
        )
        .tint(.orange)

        // With different label color
        CalendarMonthLabel(
            formattedLabel: previewMonth.formatted(.dateTime.month(.wide).year()),
            isActive: isPickerPresented,
            action: { isPickerPresented.toggle() },
            labelColor: .red
        )
        .tint(.green)

        // With tint (affects chevron only)
        CalendarMonthLabel(
            formattedLabel: previewMonth.formatted(.dateTime.month(.wide).year()),
            isActive: isPickerPresented,
            action: { isPickerPresented.toggle() },
            labelColor: .green
        )
        .tint(.orange)

        // CalendarMonthNavigationHeader with custom tint
        CalendarMonthNavigationHeader(
            month: $previewMonth,
            isMonthYearPickerPresented: $isPickerPresented
        )
        .tint(.purple)

        // Show picker state
        Text("Picker presented: \(isPickerPresented ? "Yes" : "No")")
            .font(.caption)
            .foregroundColor(.secondary)

        Text("Month: \(previewMonth.formatted(.dateTime.month(.wide).year()))")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
