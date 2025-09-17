import SwiftUI
import Time
import UIKit

public struct CalendarPagerConfiguration {
    public let region: Region
    public let navigationOrientation: UIPageViewController.NavigationOrientation
    public let transitionStyle: UIPageViewController.TransitionStyle

    public init(
        region: Region = .autoupdatingCurrent,
        navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll
    ) {
        self.region = region
        self.navigationOrientation = navigationOrientation
        self.transitionStyle = transitionStyle
    }
}

public struct CalendarPager<Content: View>: UIViewControllerRepresentable {
    @Binding var keyPeriod: Fixed<Month>
    let content: (Fixed<Month>) -> Content
    let config: CalendarPagerConfiguration

    public init(
        config: CalendarPagerConfiguration = .init(),
        _ keyPeriod: Binding<Fixed<Month>>,
        @ViewBuilder content: @escaping (Fixed<Month>) -> Content
    ) {
        self.config = config
        self.content = content
        _keyPeriod = keyPeriod
    }

    public func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: config.transitionStyle,
            navigationOrientation: config.navigationOrientation,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 0]
        )

        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        // Set initial page
        let initialPage = context.coordinator.createPage(for: keyPeriod)
        pageViewController.setViewControllers([initialPage], direction: .forward, animated: false)

        return pageViewController
    }

    public func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        // Update parent to access the content
        context.coordinator.parent = self

        let displayedKeyPeriod = context.coordinator.keyPeriod
        let newPage = context.coordinator.createPage(for: keyPeriod)

        let direction: UIPageViewController.NavigationDirection = keyPeriod.isAfter(displayedKeyPeriod) ? .forward : .reverse
        let animated = keyPeriod.month != displayedKeyPeriod.month
        pageViewController.setViewControllers([newPage], direction: direction, animated: animated)

        // Update the Coordinator's keyPeriod value
        context.coordinator.keyPeriod = keyPeriod
    }

    public func sizeThatFits(
        _: ProposedViewSize,
        uiViewController: UIPageViewController,
        context _: Context
    ) -> CGSize? {
        // Ask the current child for its size
        guard let current = uiViewController.viewControllers?.first else { return nil }
        return current.view.intrinsicContentSize
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CalendarPager
        var keyPeriod: Fixed<Month>

        private var config: CalendarPagerConfiguration {
            parent.config
        }

        init(_ parent: CalendarPager, keyPeriod: Fixed<Month>? = nil) {
            self.parent = parent
            self.keyPeriod = keyPeriod ?? parent.keyPeriod
            super.init()
        }

        func createPage(for period: Fixed<Month>) -> UIHostingController<Content> {
            let difference = keyPeriod.differenceInWholeMonths(to: period)

            let view = parent.content(period)
            let hostingController = UIHostingController(rootView: view)

            hostingController.view.tag = difference.months
            hostingController.view.backgroundColor = UIColor.clear

            return hostingController
        }

        // MARK: - UIPageViewControllerDataSource

        public func pageViewController(_: UIPageViewController, viewControllerBefore _: UIViewController) -> UIViewController? {
            return createPage(for: keyPeriod.previousMonth)
        }

        public func pageViewController(_: UIPageViewController, viewControllerAfter _: UIViewController) -> UIViewController? {
            return createPage(for: keyPeriod.nextMonth)
        }

        // MARK: - UIPageViewControllerDelegate

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers _: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed,
                  let currentViewController = pageViewController.viewControllers?.first,
                  let hostingController = currentViewController as? UIHostingController<Content> else { return }

            let monthOffset = hostingController.view.tag
            let newKeyPeriod = keyPeriod.adding(months: monthOffset)
            keyPeriod = newKeyPeriod
            // Update the binding
            DispatchQueue.main.async {
                self.parent.keyPeriod = newKeyPeriod
            }
        }
    }
}

