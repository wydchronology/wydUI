import SwiftUI
import Time

public struct CalendarDatePicker: View {
    @Binding var selection: Date

    @State private var keyPeriod: Fixed<Month>
    @State private var isPickerPresented: Bool = false
    private let onRangeChange: (DateInterval) -> Void
    private let config: CalendarDatePickerConfiguration

    public init(
        selection: Binding<Date>,
        onRangeChange: @escaping (DateInterval) -> Void = { _ in },
        config: CalendarDatePickerConfiguration = .init()
    ) {
        _selection = selection
        _keyPeriod = State(
            initialValue: Fixed(
                region: config.region,
                date: selection.wrappedValue
            )
        )
        self.onRangeChange = onRangeChange
        self.config = config
    }

    private var today: Fixed<Day> {
        Fixed<Day>(region: config.region, date: Date())
    }

    private var highlightedIndex: Int? {
        if today.isDuring(keyPeriod) {
            return today.dayOfWeek
        }
        return nil
    }

    private var components: CalendarDatePickerComponents {
        config.components
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: config.verticalSpacing) {
                components.toolbar($isPickerPresented, $keyPeriod, config)

                if isPickerPresented {
                    components.picker($isPickerPresented, $keyPeriod, config)
                } else {
                    VStack(spacing: config.verticalSpacing) {
                        components.weekdaySymbols(highlightedIndex, config)

                        CalendarPager($keyPeriod) { period in
                            components.page($selection, period, config)
                                .frame(minWidth: geometry.size.width)
                        }
                    }
                }
            }
            .onChange(of: keyPeriod) {
                let start = keyPeriod.firstDay.firstInstant.date
                let end = keyPeriod.lastDay.firstInstant.date
                let interval = DateInterval(start: start, end: end)
                onRangeChange(interval)
            }
        }
    }
}

#Preview("CalendarDatePicker with defaults") {
    @Previewable @State var selection = Date()

    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)

        ScrollView {
            CalendarDatePicker(selection: $selection)
                .padding()
                .tint(Color(UIColor.purple)) // Example of tinting from outside
        }
    }
}

#Preview("CalendarDatePicker") {
    @Previewable @State var selection = Date()

    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)

        ScrollView {
            CalendarDatePicker(
                selection: $selection,
                onRangeChange: { dateInterval in
                    print("dateInterval changed: \(dateInterval)")
                },
                config: CalendarDatePickerConfiguration(
                    components: CalendarDatePickerComponents(
                        toolbar: { isPresented, selection, _ in
                            CalendarDatePickerToolbar(
                                isPresented: isPresented,
                                selection: selection,
                                components: CalendarDatePickerToolbarComponents(
                                    leading: { context in
                                        Button(action: {
                                            withAnimation(.linear(duration: 0.5)) {
                                                context.isPresented.wrappedValue.toggle()
                                            }
                                        }) {
                                            Text(context.label)
                                                .font(.headline)
                                                .padding()
                                                .glassEffect(.clear.interactive(), in: .capsule)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    },
                                    // try commenting out trailing and use `config` to modify the default component
                                    trailing: { context in
                                        HStack(spacing: context.config.buttonSpacing) {
                                            Button(action: {
                                                context.decrementMonth()
                                            }) {
                                                Image(systemName: "arrow.left.circle")
                                                    .imageScale(.large)
                                            }
                                            Button(action: {
                                                context.incrementMonth()
                                            }) {
                                                Image(systemName: "arrow.right.circle")
                                                    .imageScale(.large)
                                            }
                                        }
                                    }
                                ),
                                // config: CalendarDatePickerToolbarConfiguration(
                                //     buttonSpacing: 50
                                // ),
                            )
                        },
                        cell: { selection, day, context in
                            CalendarDateCell(
                                selection: selection.wrappedValue,
                                day: day,
                                components: CalendarDateCellComponents(
                                    indicator: { _, _ in
                                        Circle()
                                            .fill(Color.pink)
                                            .frame(width: 5, height: 5)
                                    }
                                ),
                                config: CalendarDateCellConfiguration(
                                    verticalSpacing: 20,
                                    clippedShape: RoundedRectangle(cornerRadius: 5)
                                )
                            ) { day in
                                selection.wrappedValue = day.firstInstant.date
                            }
                            .frame(width: context.cellSize, height: context.cellSize + 25)
                            .buttonStyle(ClippedShapeButtonStyle(shape: RoundedRectangle(cornerRadius: 5)))
                        }
                    )
                )
            )
            .padding()
            .tint(Color(UIColor.purple)) // Example of tinting from outside
        }
    }
}

#Preview("Custom Toolbar Example") {
    @Previewable @State var selection = Date()

    VStack(spacing: 20) {
        Text("Custom Toolbar Example")
            .font(.headline)

        CalendarDatePicker(
            selection: $selection,
            config: CalendarDatePickerConfiguration(
                components: CalendarDatePickerComponents(
                    toolbar: { isPresented, selection, _ in
                        HStack {
                            Button(action: {
                                // Custom previous action
                                selection.wrappedValue = selection.wrappedValue.previousMonth
                            }) {
                                Image(systemName: "arrow.left")
                                    .imageScale(.large)
                            }

                            Spacer()

                            Text(selection.wrappedValue.format(month: .abbreviatedName))
                                .font(.headline)
                                .onTapGesture {
                                    isPresented.wrappedValue.toggle()
                                }

                            Spacer()

                            Button(action: {
                                // Custom next action
                                selection.wrappedValue = selection.wrappedValue.nextMonth
                            }) {
                                Image(systemName: "arrow.right")
                                    .imageScale(.large)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    })
            )
        )
        
        Spacer()
    }
    .padding()
}
