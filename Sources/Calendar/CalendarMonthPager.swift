import SwiftUI
import UIKit

struct CalendarMonthPager<Content: View>: UIViewControllerRepresentable {
    let content: (Date) -> Content
    @Binding var selection: Date
    let calendar: Calendar

    init(
        calendar: Calendar = .autoupdatingCurrent,
        selection: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        self.calendar = calendar
        _selection = selection
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 0]
        )

        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        // Set background color
        pageViewController.view.backgroundColor = UIColor.clear

        // Set initial page
        let initialPage = context.coordinator.createPage(for: selection)
        pageViewController.setViewControllers([initialPage], direction: .forward, animated: false)

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        // Update parent to access the content
        context.coordinator.parent = self

        // Update currently rendered page if the binding changed externally
        if let activeViewController = pageViewController.viewControllers?.first as? UIHostingController<Content> {
            let currentMonthOffset = activeViewController.view.tag
            let currentPageDate = context.coordinator.getDate(for: currentMonthOffset)

            let currentMonth = calendar.dateInterval(of: .month, for: currentPageDate)?.start ?? currentPageDate
            let newMonth = calendar.dateInterval(of: .month, for: selection)?.start ?? selection

            let newPage = context.coordinator.createPage(for: selection)
            let newMonthOffset = newPage.view.tag

            let direction: UIPageViewController.NavigationDirection = newMonthOffset > currentMonthOffset ? .forward : .reverse
            let animated = currentMonth != newMonth
            pageViewController.setViewControllers([newPage], direction: direction, animated: animated)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CalendarMonthPager
        private let calendar = Calendar.autoupdatingCurrent
        private let referenceDate: Date

        init(_ parent: CalendarMonthPager) {
            self.parent = parent
            referenceDate = parent.selection
            super.init()
        }

        func createPage(for date: Date) -> UIHostingController<Content> {
            let view = parent.content(date)
            let hostingController = UIHostingController(rootView: view)
            let monthOffset = getMonthOffset(for: date)
            hostingController.view.tag = monthOffset
            return hostingController
        }

        func getDate(for monthOffset: Int) -> Date {
            return calendar.date(byAdding: .month, value: monthOffset, to: referenceDate) ?? referenceDate
        }

        func getMonthOffset(for date: Date) -> Int {
            return calendar.dateComponents([.month], from: referenceDate, to: date).month ?? 0
        }

        // MARK: - UIPageViewControllerDataSource

        func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let hostingController = viewController as? UIHostingController<Content> else { return nil }

            let currentMonthOffset = hostingController.view.tag
            let previousDate = getDate(for: currentMonthOffset - 1)
            return createPage(for: previousDate)
        }

        func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let hostingController = viewController as? UIHostingController<Content> else { return nil }

            let currentMonthOffset = hostingController.view.tag
            let nextDate = getDate(for: currentMonthOffset + 1)
            return createPage(for: nextDate)
        }

        // MARK: - UIPageViewControllerDelegate

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
            guard completed,
                  let currentViewController = pageViewController.viewControllers?.first,
                  let hostingController = currentViewController as? UIHostingController<Content> else { return }

            let currentMonthOffset = hostingController.view.tag
            let newDate = getDate(for: currentMonthOffset)

            // Update the binding
            DispatchQueue.main.async {
                self.parent.selection = newDate
            }
        }
    }
}

// MARK: - Preview and Example Usage

#Preview {
    @Previewable @State var currentDate = Date()

    VStack(spacing: 20) {
        Text("Infinite Calendar Carousel")
            .font(.headline)

        Text("Current Month: \(currentDate.formatted(.dateTime.month(.wide).year()))")
            .font(.subheadline)
            .foregroundColor(.secondary)

        CalendarMonthPager(selection: $currentDate) { month in
            CalendarMonthGrid(month: month) { day, _ in
                if let day = day {
                    Text("\(day)")
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Color.clear
                        .frame(width: 40, height: 40)
                }
            }
        }
        .frame(height: 300)
        .cornerRadius(12)

        HStack(spacing: 20) {
            Button("Previous Month") {
                withAnimation {
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }
            }
            .buttonStyle(.bordered)

            Button("Next Month") {
                withAnimation {
                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }
            }
            .buttonStyle(.bordered)
        }
    }
    .padding()
}
