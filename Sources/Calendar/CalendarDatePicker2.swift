import SwiftUI
import Time

public struct CalendarDatePickerConfiguration: Sendable {
    let verticalSpacing: CGFloat

    public init(
        verticalSpacing: CGFloat = 0
    ) {
        self.verticalSpacing = verticalSpacing
    }
}

@MainActor
public struct CalendarDatePickerComponents: Sendable {
    let toolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView
    let picker: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> AnyView

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

    public init() {
        toolbar = Self.defaultToolbar
        picker = Self.defaultPicker
    }

    public init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
    ) {
        self.toolbar = { isPresented, selection in
            AnyView(toolbar(isPresented, selection))
        }
        picker = Self.defaultPicker
    }

    public init(
        @ViewBuilder toolbar: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View,
        @ViewBuilder picker: @escaping (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>) -> some View
    ) {
        self.toolbar = { selection, isPresented in
            AnyView(toolbar(selection, isPresented))
        }
        self.picker = { isPresented, selection in
            AnyView(picker(isPresented, selection))
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
        region: Region = .autoupdatingCurrent,
        selection: Binding<Date>,
        onRangeChange: @escaping (DateInterval) -> Void = { _ in },
        components: CalendarDatePickerComponents = .init(),
        config: CalendarDatePickerConfiguration = .init()
    ) {
        _selection = selection
        _keyPeriod = State(
            initialValue: Fixed(
                region: region,
                date: selection.wrappedValue
            )
        )
        self.onRangeChange = onRangeChange
        self.config = config
        self.components = components
    }

    public var body: some View {
        VStack(spacing: config.verticalSpacing) {
            components.toolbar($isPickerPresented, $keyPeriod)

            if isPickerPresented {
                components.picker($isPickerPresented, $keyPeriod)
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
            components: CalendarDatePickerComponents { isPresented, selection in
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
            }
        )
        .padding()
    }
}
