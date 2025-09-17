import SwiftUI
import Time

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
            CalendarMonthYearPicker(
                isPresented: isPresented,
                selection: selection,
            )
        )
    }

    static let defaultToolbar: (_ isPresented: Binding<Bool>, _ selection: Binding<Fixed<Month>>, _ context: CalendarDatePickerConfiguration) -> AnyView = { isPresented, selection, context in
        AnyView(
            CalendarDatePickerToolbar(
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
            CalendarMonthGrid(
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
            CalendarDateCell(selection: selection.wrappedValue, day: day) { day in
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