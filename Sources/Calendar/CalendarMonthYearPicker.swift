import SwiftUI
import UIKit

struct CalendarMonthYearPicker: View {
    @Binding var selection: Date
    @Binding var isPresented: Bool
    var mode: UIDatePicker.Mode = .yearAndMonth
    var style: UIDatePickerStyle = .wheels

    var body: some View {
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
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
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
