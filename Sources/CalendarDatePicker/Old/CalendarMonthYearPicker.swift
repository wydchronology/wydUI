import SwiftUI
import UIKit

public struct CalendarMonthYearPicker: View {
    @Binding var selection: Date
    @Binding var isPresented: Bool
    var mode: UIDatePicker.Mode = .yearAndMonth
    var style: UIDatePickerStyle = .wheels

    public init(
        selection: Binding<Date>,
        isPresented: Binding<Bool>,
        mode: UIDatePicker.Mode = .yearAndMonth,
        style: UIDatePickerStyle = .wheels
    ) {
        _selection = selection
        _isPresented = isPresented
        self.mode = mode
        self.style = style
    }

    public var body: some View {
        UIDatePickerRepresentable(
            selection: $selection,
            mode: mode,
            style: style
        )
    }
}

struct UIDatePickerRepresentable: UIViewRepresentable {
    @Binding var selection: Date
    let mode: UIDatePicker.Mode
    let style: UIDatePickerStyle

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = style
        picker.date = selection

        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context _: Context) {
        uiView.date = selection
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: UIDatePickerRepresentable

        init(_ parent: UIDatePickerRepresentable) {
            self.parent = parent
        }

        @MainActor @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selection = sender.date
        }
    }
}
