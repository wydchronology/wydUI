import SwiftUI
import Time

public struct CalendarDatePickerConfiguration: Sendable {
    let region: Region
    let verticalSpacing: CGFloat
    let weekdaySymbolsVerticalPadding: CGFloat
    let toolbarHorizontalPadding: CGFloat

    public init(
        region: Region = .autoupdatingCurrent,
        verticalSpacing: CGFloat = 0,
        weekdaySymbolsVerticalPadding: CGFloat = 10,
        toolbarHorizontalPadding: CGFloat = 10
    ) {
        self.region = region
        self.verticalSpacing = verticalSpacing
        self.weekdaySymbolsVerticalPadding = weekdaySymbolsVerticalPadding
        self.toolbarHorizontalPadding = toolbarHorizontalPadding
    }
}

@MainActor
public struct CalendarDatePickerComponents: Sendable {
    let toolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView
    let picker: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView
    let weekdaySymbols: (_ selection: Int?) -> AnyView

    public init() {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
        weekdaySymbols = Self.defaultWeekdaySymbols
    }
}

public extension CalendarDatePickerComponents {
    static let defaultPicker: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView = { isPresented, selection in
        AnyView(
            CalendarMonthYearPicker2(
                isPresented: isPresented,
                selection: selection,
            )
        )
    }

    static let defaultToolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView = { isPresented, selection in
        AnyView(
            CalendarDatePickerToolbar2(
                isPresented: isPresented,
                selection: selection,
            )
        )
    }

    static let defaultWeekdaySymbols: (_ highlightedIndex: Int?) -> AnyView = { highlightedIndex in
        AnyView(
            CalendarWeekdaySymbols(highlightedIndex: highlightedIndex)
        )
    }
}

public extension CalendarDatePickerComponents {
    init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
    ) {
        self.toolbar = { isPresented, selection in
            AnyView(toolbar(isPresented, selection))
        }
        picker = Self.defaultPicker
        weekdaySymbols = Self.defaultWeekdaySymbols
    }

    init(
        @ViewBuilder picker: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
    ) {
        toolbar = Self.defaultToolbar
        weekdaySymbols = Self.defaultWeekdaySymbols
        self.picker = { isPresented, selection in
            AnyView(picker(isPresented, selection))
        }
    }

    init(
        @ViewBuilder weekdaySymbols: @escaping (_ highlightedIndex: Int?) -> some View
    ) {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
        self.weekdaySymbols = { highlightedIndex in
            AnyView(weekdaySymbols(highlightedIndex))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder picker: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
    ) {
        weekdaySymbols = Self.defaultWeekdaySymbols
        self.toolbar = { isPresented, selection in
            AnyView(toolbar(isPresented, selection))
        }
        self.picker = { isPresented, selection in
            AnyView(picker(isPresented, selection))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (_ highlightedIndex: Int?) -> some View
    ) {
        picker = Self.defaultPicker
        self.toolbar = { isPresented, selection in
            AnyView(toolbar(isPresented, selection))
        }
        self.weekdaySymbols = { highlightedIndex in
            AnyView(weekdaySymbols(highlightedIndex))
        }
    }

    init(
        @ViewBuilder picker: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (_ highlightedIndex: Int?) -> some View
    ) {
        toolbar = Self.defaultToolbar
        self.picker = { isPresented, selection in
            AnyView(picker(isPresented, selection))
        }
        self.weekdaySymbols = { highlightedIndex in
            AnyView(weekdaySymbols(highlightedIndex))
        }
    }

    init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder picker: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder weekdaySymbols: @escaping (_ highlightedIndex: Int?) -> some View
    ) {
        self.toolbar = { selection, isPresented in
            AnyView(toolbar(selection, isPresented))
        }
        self.picker = { isPresented, selection in
            AnyView(picker(isPresented, selection))
        }
        self.weekdaySymbols = { highlightedIndex in
            AnyView(weekdaySymbols(highlightedIndex))
        }
    }
}

public struct CalendarDatePicker2: View {
    @Binding var selection: Date

    @State private var keyPeriod: Fixed<Month>
    @State private var isPickerPresented: Bool = false
    private let onRangeChange: (DateInterval) -> Void
    private let config: CalendarDatePickerConfiguration
    private let components: CalendarDatePickerComponents

    public init(
        selection: Binding<Date>,
        onRangeChange: @escaping (DateInterval) -> Void = { _ in },
        components: CalendarDatePickerComponents = .init(),
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
        self.components = components
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

    public var body: some View {
        VStack(spacing: config.verticalSpacing) {
            components.toolbar($isPickerPresented, $keyPeriod)
                .padding(.horizontal, config.toolbarHorizontalPadding)

            if isPickerPresented {
                components.picker($isPickerPresented, $keyPeriod)
            } else {
                VStack(spacing: 0) {
                    components.weekdaySymbols(highlightedIndex)
                        .padding(.vertical, config.weekdaySymbolsVerticalPadding)
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
                components: CalendarDatePickerComponents(
                    toolbar: { isPresented, selection in
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
                    }
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
            components: CalendarDatePickerComponents(
                toolbar: { isPresented, selection in
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
        .padding()
    }
}
