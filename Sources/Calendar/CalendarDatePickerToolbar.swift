import SwiftUI

struct CalendarDatePickerToolbar<Label: View, Previous: View, Next: View>: View {
    @Binding var selection: Date
    @Binding var isMonthYearPickerPresented: Bool

    let label: (Date, String, Binding<Bool>) -> Label
    let previous: (@escaping () -> Void) -> Previous
    let next: (@escaping () -> Void) -> Next

    var buttonSpacing: CGFloat = 20

    init(
        selection: Binding<Date>,
        isMonthYearPickerPresented: Binding<Bool> = .constant(false),
        @ViewBuilder label: @escaping (Date, String, Binding<Bool>) -> Label = { _, formattedLabel, isPresentedBinding in
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
        },
        @ViewBuilder previous: @escaping (@escaping () -> Void) -> Previous = { action in
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .buttonStyle(.borderless)
        },
        @ViewBuilder next: @escaping (@escaping () -> Void) -> Next = { action in
            Button(action: action) {
                Image(systemName: "chevron.right")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .buttonStyle(.borderless)
        }
    ) {
        _selection = selection
        _isMonthYearPickerPresented = isMonthYearPickerPresented
        self.label = label
        self.previous = previous
        self.next = next
    }

    private var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selection)
    }

    private func incrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            selection = Calendar.current.date(byAdding: .month, value: 1, to: selection) ?? selection
        }
    }

    private func decrementMonth() {
        withAnimation(.interactiveSpring(duration: 0.3)) {
            selection = Calendar.current.date(byAdding: .month, value: -1, to: selection) ?? selection
        }
    }

    var body: some View {
        HStack(spacing: .zero) {
            Spacer()
            label(selection, monthYearLabel, $isMonthYearPickerPresented)

            Spacer()

            if !isMonthYearPickerPresented {
                HStack(spacing: buttonSpacing) {
                    previous(decrementMonth)
                    next(incrementMonth)
                }
                Spacer()
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
        CalendarDatePickerToolbar(
            selection: $previewMonth,
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
