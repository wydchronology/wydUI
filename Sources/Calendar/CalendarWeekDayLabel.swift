import SwiftUI

struct CalendarWeekDayLabel: View {
    private let weekDaySymbols: [String]
    private let textLabelBuilder: (String) -> AnyView

    init(textLabelBuilder: @escaping (String) -> AnyView = { day in
        AnyView(
            Text(day)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        )
    }) {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        weekDaySymbols = formatter.shortWeekdaySymbols.map { $0.uppercased() }
        self.textLabelBuilder = textLabelBuilder
    }

    var body: some View {
        HStack {
            ForEach(weekDaySymbols, id: \.self) { day in
                textLabelBuilder(day)

                if day != weekDaySymbols.last {
                    Spacer()
                }
            }
        }
    }
}
