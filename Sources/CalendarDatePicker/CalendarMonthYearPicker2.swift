import SwiftUI
import Time
import UIKit

public struct CalendarMonthYearPicker2: View {
    @Binding var isPresented: Bool
    @Binding var selection: Fixed<Month>
    let region: Region
    let mode: UIDatePicker.Mode
    let style: UIDatePickerStyle

    public init(
        region: Region = .autoupdatingCurrent,
        isPresented: Binding<Bool>,
        selection: Binding<Fixed<Month>>,
        mode: UIDatePicker.Mode = .yearAndMonth,
        style: UIDatePickerStyle = .wheels
    ) {
        _isPresented = isPresented
        _selection = selection
        self.region = region
        self.mode = mode
        self.style = style
    }

    public var body: some View {
        UIDatePickerRepresentable2(
            selection: $selection,
            region: region,
            mode: mode,
            style: style
        )
    }
}

struct UIDatePickerRepresentable2: UIViewRepresentable {
    @Binding var selection: Fixed<Month>
    let region: Region
    let mode: UIDatePicker.Mode
    let style: UIDatePickerStyle

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = style
        picker.date = selection.firstInstant.date

        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context _: Context) {
        uiView.date = selection.firstInstant.date
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: UIDatePickerRepresentable2

        init(_ parent: UIDatePickerRepresentable2) {
            self.parent = parent
        }

        @MainActor @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selection = Fixed(
                region: parent.region,
                date: sender.date
            )
        }
    }
}
