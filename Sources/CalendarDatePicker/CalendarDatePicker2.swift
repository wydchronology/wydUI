import SwiftUI
import Time

@MainActor
public struct CalendarDatePickerConfiguration: Sendable {
    let region: Region
    let components: CalendarDatePickerComponents
    let verticalSpacing: CGFloat
    let horizontalPadding: CGFloat
    let cellSize: CGFloat

    public init(
        region: Region = .autoupdatingCurrent,
        components: CalendarDatePickerComponents = .init(),
        verticalSpacing: CGFloat = 10,
        horizontalPadding: CGFloat = 10,
        cellSize: CGFloat = 42,
    ) {
        self.region = region
        self.components = components
        self.verticalSpacing = verticalSpacing
        self.horizontalPadding = horizontalPadding
        self.cellSize = cellSize
    }
}

@MainActor
public struct CalendarDatePickerComponents: Sendable {
    let toolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>, _ context: CalendarDatePickerConfiguration) -> AnyView
    let picker: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>, _ context: CalendarDatePickerConfiguration) -> AnyView
    let weekdaySymbols: (_ selection: Int?, _ context: CalendarDatePickerConfiguration) -> AnyView
    let page: (_ selection: Binding<Date>, _ period: Fixed<Month>, _ context: CalendarDatePickerConfiguration) -> AnyView
    let cell: (_ selection: Binding<Date>, _ day: Fixed<Day>?, _ context: CalendarDatePickerConfiguration) -> AnyView

    public init() {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
        weekdaySymbols = Self.defaultWeekdaySymbols
        page = Self.defaultPage
        cell = Self.defaultCell
    }
}

public extension CalendarDatePickerComponents {
    static let defaultPicker: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>, _ context: CalendarDatePickerConfiguration) -> AnyView = { isPresented, selection, _ in
        AnyView(
            CalendarMonthYearPicker2(
                isPresented: isPresented,
                selection: selection,
            )
        )
    }

    static let defaultToolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>, _ context: CalendarDatePickerConfiguration) -> AnyView = { isPresented, selection, context in
        AnyView(
            CalendarDatePickerToolbar2(
                isPresented: isPresented,
                selection: selection,
            )
            .padding(.horizontal, context.horizontalPadding)
        )
    }

    static let defaultWeekdaySymbols: (_ highlightedIndex: Int?, _ context: CalendarDatePickerConfiguration) -> AnyView = { highlightedIndex, context in
        AnyView(
            CalendarWeekdaySymbols(highlightedIndex: highlightedIndex)
                .padding(.top, context.verticalSpacing)
        )
    }

    static let defaultPage: (_ selection: Binding<Date>, _ period: Fixed<Month>, _ context: CalendarDatePickerConfiguration) -> AnyView = { selection, period, context in
        AnyView(
            CalendarMonthGrid2(
                month: period,
                components: CalendarMonthGridComponents(
                    cell: { day in
                        context.components.cell(selection, day, context)
                    }
                )
            )
        )
    }

    static let defaultCell: (_ selection: Binding<Date>, _ day: Fixed<Day>?, _ context: CalendarDatePickerConfiguration) -> AnyView = { selection, day, context in
        AnyView(
            CalendarDateCell2(selection: selection.wrappedValue, day: day) { day in
                selection.wrappedValue = day.firstInstant.date
            }
            .buttonStyle(ClippedShapeButtonStyle(shape: Circle()))
            .frame(width: context.cellSize, height: context.cellSize)
        )
    }
}

public extension CalendarDatePickerComponents {
    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
    ) {
        picker = Self.defaultPicker
        weekdaySymbols = Self.defaultWeekdaySymbols
        page = Self.defaultPage
        cell = Self.defaultCell
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
    }

    init(
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
    ) {
        toolbar = Self.defaultToolbar
        weekdaySymbols = Self.defaultWeekdaySymbols
        page = Self.defaultPage
        cell = Self.defaultCell
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
    }

    init(
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
        page = Self.defaultPage
        cell = Self.defaultCell
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
    }

    init(
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
        weekdaySymbols = Self.defaultWeekdaySymbols
        cell = Self.defaultCell
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
    ) {
        weekdaySymbols = Self.defaultWeekdaySymbols
        page = Self.defaultPage
        cell = Self.defaultCell
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        picker = Self.defaultPicker
        page = Self.defaultPage
        cell = Self.defaultCell
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder cell: @escaping (
            _ selection: Binding<Date>,
            _ day: Fixed<Day>?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        weekdaySymbols = Self.defaultWeekdaySymbols
        page = Self.defaultPage
        picker = Self.defaultPicker
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
        self.cell = { selection, day, context in
            AnyView(cell(selection, day, context))
        }
    }

    init(
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        toolbar = Self.defaultToolbar
        page = Self.defaultPage
        cell = Self.defaultCell
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        picker = Self.defaultPicker
        cell = Self.defaultCell
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        weekdaySymbols = Self.defaultWeekdaySymbols
        cell = Self.defaultCell
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
        self.toolbar = { isPresented, selection, context in
            AnyView(toolbar(isPresented, selection, context))
        }
    }

    init(
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder cell: @escaping (
            _ selection: Binding<Date>,
            _ day: Fixed<Day>?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        weekdaySymbols = Self.defaultWeekdaySymbols
        toolbar = Self.defaultToolbar
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
        self.cell = { selection, day, context in
            AnyView(cell(selection, day, context))
        }
    }

    init(
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        toolbar = Self.defaultToolbar
        cell = Self.defaultCell
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder picker: @escaping (
            _ isPresented: Binding<Bool>,
            _ selection: Binding<Fixed<Month>>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (
            _ highlightedIndex: Int?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder page: @escaping (
            _ selection: Binding<Date>,
            _ period: Fixed<Month>,
            _ context: CalendarDatePickerConfiguration
        ) -> some View,
        @ViewBuilder cell: @escaping (
            _ selection: Binding<Date>,
            _ day: Fixed<Day>?,
            _ context: CalendarDatePickerConfiguration
        ) -> some View
    ) {
        self.toolbar = { selection, isPresented, context in
            AnyView(toolbar(selection, isPresented, context))
        }
        self.picker = { isPresented, selection, context in
            AnyView(picker(isPresented, selection, context))
        }
        self.weekdaySymbols = { highlightedIndex, context in
            AnyView(weekdaySymbols(highlightedIndex, context))
        }
        self.page = { selection, period, context in
            AnyView(page(selection, period, context))
        }
        self.cell = { selection, day, context in
            AnyView(cell(selection, day, context))
        }
    }
}

public struct CalendarDatePicker2: View {
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
                                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
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
            CalendarDatePicker2(selection: $selection)
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
            CalendarDatePicker2(
                selection: $selection,
                onRangeChange: { dateInterval in
                    print("dateInterval changed: \(dateInterval)")
                },
                config: CalendarDatePickerConfiguration(
                    components: CalendarDatePickerComponents(
                        toolbar: { isPresented, selection, _ in
                            CalendarDatePickerToolbar2(
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
                                            Button("←") {
                                                context.decrementMonth()
                                            }
                                            Button("→") {
                                                context.incrementMonth()
                                            }
                                        }
                                    }
                                ),
                                // config: CalendarDatePickerToolbarConfig(
                                //     buttonSpacing: 50
                                // ),
                            )
                        },
                        cell: { selection, day, context in
                            CalendarDateCell2(
                                selection: selection.wrappedValue,
                                day: day,
                                components: CalendarDateCell2Components(
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

        CalendarDatePicker2(
            selection: $selection,
            config: CalendarDatePickerConfiguration(
                components: CalendarDatePickerComponents(
                    toolbar: { isPresented, selection, _ in
                        HStack {
                            Button("←") {
                                // Custom previous action
                                selection.wrappedValue = selection.wrappedValue.previousMonth
                            }

                            Spacer()

                            Text(selection.wrappedValue.format(month: .abbreviatedName))
                                .font(.headline)
                                .onTapGesture {
                                    isPresented.wrappedValue.toggle()
                                }

                            Spacer()

                            Button("→") {
                                // Custom next action
                                selection.wrappedValue = selection.wrappedValue.nextMonth
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    })
            )
        )
        .padding()
    }
}
