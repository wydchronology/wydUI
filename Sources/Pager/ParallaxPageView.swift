import SwiftUI
import UIKit

public protocol ParallaxPager: View {
    associatedtype Content: View

    var page: Binding<Int> { get }
    var disabled: Bool { get set }

    var content: () -> Content { get }
}

// MARK: - Configuration

public struct ParallaxPageViewConfiguration: Sendable {
    /// Duration of transition animations (default: 0.35)
    public var animationDuration: CGFloat

    /// Minimum alpha for the underneath page when fully covered (default: 0.4)
    public var minimumAlpha: CGFloat

    /// Animation style for transitions (default: .snappy)
    public var animationStyle: AnimationStyle

    /// Edge threshold for swipe detection as fraction of screen width (default: 0.3)
    /// Swipes must start within this fraction from the left/right edge
    public var swipeEdgeThreshold: CGFloat

    /// How much the underneath page moves during parallax as fraction of width (default: 0.3)
    public var parallaxAmount: CGFloat

    public enum AnimationStyle: Sendable {
        case snappy
        case easeOut
        case linear
        case spring(dampingRatio: CGFloat)
    }

    public init(
        animationDuration: CGFloat = 0.35,
        minimumAlpha: CGFloat = 0.4,
        animationStyle: AnimationStyle = .snappy,
        swipeEdgeThreshold: CGFloat = 0.3,
        parallaxAmount: CGFloat = 0.25
    ) {
        self.animationDuration = animationDuration
        self.minimumAlpha = minimumAlpha
        self.animationStyle = animationStyle
        self.swipeEdgeThreshold = swipeEdgeThreshold
        self.parallaxAmount = parallaxAmount
    }

    public static let `default` = ParallaxPageViewConfiguration()
}

// MARK: - Transition Mask State

/// Observable state for controlling mask visibility during transitions.
/// Shared between UIKit and SwiftUI layers.
@MainActor
final class TransitionMaskState: ObservableObject {
    @Published var isApplied = false
}

// MARK: - Masked Content Wrapper

/// Wraps content and conditionally applies a mask shape during transitions.
/// The mask is applied in SwiftUI context, so ContainerRelativeShape works correctly.
private struct MaskedPageContent<Content: View, MaskShape: Shape>: View {
    let content: Content
    let maskShape: MaskShape
    @ObservedObject var maskState: TransitionMaskState

    var body: some View {
        content
            .mask {
                if maskState.isApplied {
                    maskShape
                } else {
                    Rectangle()
                }
            }
    }
}

/// Type-erased mask shape provider that creates the masked wrapper view.
struct AnyMaskShapeProvider: @unchecked Sendable {
    private let _wrap: @MainActor (AnyView, TransitionMaskState) -> AnyView

    init<S: Shape>(_ shape: S) {
        _wrap = { content, state in
            AnyView(
                MaskedPageContent(content: content, maskShape: shape, maskState: state)
                    .ignoresSafeArea()
            )
        }
    }

    @MainActor
    func wrap(_ content: AnyView, state: TransitionMaskState) -> AnyView {
        _wrap(content, state)
    }
}

// MARK: - Public API

public struct ParallaxPageView<Content: View, MaskShape: Shape>: ParallaxPager {
    public var page: Binding<Int>
    public var disabled: Bool = false
    public var configuration: ParallaxPageViewConfiguration

    /// Optional mask shape applied to the top page during transitions.
    /// Evaluated in SwiftUI context, so ContainerRelativeShape works correctly.
    public var maskShape: MaskShape?

    @ViewBuilder
    public let content: () -> Content

    public init(
        page: Binding<Int>,
        disabled: Bool = false,
        configuration: ParallaxPageViewConfiguration = .default,
        maskShape: MaskShape? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.page = page
        self.disabled = disabled
        self.configuration = configuration
        self.maskShape = maskShape
        self.content = content
    }

    public var body: some View {
        Group(subviews: content()) { views in
            SwipePagerRepresentable(
                page: page,
                disabled: disabled,
                configuration: configuration,
                maskShapeProvider: maskShape.map { AnyMaskShapeProvider($0) },
                content: {
                    AnyView(views[$0])
                },
                viewCount: views.count
            )
            .ignoresSafeArea()
        }
    }
}

// Convenience initializer for no mask
public extension ParallaxPageView where MaskShape == Rectangle {
    init(
        page: Binding<Int>,
        disabled: Bool = false,
        configuration: ParallaxPageViewConfiguration = .default,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.page = page
        self.disabled = disabled
        self.configuration = configuration
        maskShape = nil
        self.content = content
    }
}

// MARK: - UIKit Bridge

private struct SwipePagerRepresentable: UIViewControllerRepresentable {
    @Binding var page: Int
    let disabled: Bool
    let configuration: ParallaxPageViewConfiguration
    let maskShapeProvider: AnyMaskShapeProvider?
    let content: (Int) -> AnyView
    let viewCount: Int

    func makeUIViewController(context _: Context) -> ParallaxViewController {
        // Create mask states for each page
        let maskStates = (0 ..< viewCount).map { _ in TransitionMaskState() }

        // Create hosting controllers with masked content
        let controllers = (0 ..< viewCount).map { index -> UIHostingController<AnyView> in
            let pageContent = content(index)
            let wrappedContent: AnyView

            if let provider = maskShapeProvider {
                wrappedContent = provider.wrap(pageContent, state: maskStates[index])
            } else {
                wrappedContent = pageContent
            }

            let hc = UIHostingController(rootView: wrappedContent)
            hc.view.backgroundColor = .clear
            return hc
        }

        let vc = ParallaxViewController(
            controllers: controllers,
            configuration: configuration,
            maskStates: maskStates
        )
        vc.onIndexChange = { newIndex in
            guard newIndex != page else { return }
            page = newIndex
        }
        return vc
    }

    func updateUIViewController(_ vc: ParallaxViewController, context _: Context) {
        vc.setCurrentIndex(page, animated: true)
        vc.panGesture.isEnabled = !disabled
        vc.configuration = configuration
    }
}

// MARK: - View Controller

private final class ParallaxViewController: UIViewController {
    // MARK: Configuration

    var configuration: ParallaxPageViewConfiguration

    private var animationDuration: CGFloat { configuration.animationDuration }
    private var minimumAlpha: CGFloat { configuration.minimumAlpha }
    private var swipeEdgeThreshold: CGFloat { configuration.swipeEdgeThreshold }
    private var parallaxAmount: CGFloat { configuration.parallaxAmount }

    private var timingParameters: UITimingCurveProvider {
        switch configuration.animationStyle {
        case .snappy:
            return UISpringTimingParameters(dampingRatio: 0.85, initialVelocity: .zero)
        case .easeOut:
            return UICubicTimingParameters(animationCurve: .easeOut)
        case .linear:
            return UICubicTimingParameters(animationCurve: .linear)
        case let .spring(dampingRatio):
            return UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: .zero)
        }
    }

    // MARK: State

    private let controllers: [UIViewController]

    /// Mask states for each page, toggled during transitions.
    private let maskStates: [TransitionMaskState]

    private(set) var currentIndex: Int = 0 {
        didSet { if currentIndex != oldValue { onIndexChange?(currentIndex) } }
    }

    var onIndexChange: ((Int) -> Void)?

    // MARK: Gesture State

    private(set) var panGesture: UIPanGestureRecognizer!
    private var animator: UIViewPropertyAnimator?
    private var interaction: InteractionState?

    private struct InteractionState {
        let direction: SwipeDirection
        let targetIndex: Int
        let leftIndex: Int
        var completingToTarget = false
    }

    private enum SwipeDirection {
        case left // go to next (higher index)
        case right // go to previous (lower index)
    }

    // MARK: Init

    init(
        controllers: [UIViewController],
        configuration: ParallaxPageViewConfiguration,
        maskStates: [TransitionMaskState]
    ) {
        self.controllers = controllers
        self.configuration = configuration
        self.maskStates = maskStates
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPages()
        setupGesture()
    }

    // MARK: Setup

    private func setupPages() {
        guard !controllers.isEmpty else { return }

        for (index, vc) in controllers.enumerated() {
            embed(vc)
            vc.view.isHidden = index != currentIndex
        }

        controllers[currentIndex].view.applyShadow()
        reorderViewStack()
    }

    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    private func embed(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
    }

    private func reorderViewStack() {
        for (idx, vc) in controllers.enumerated() {
            vc.view.layer.zPosition = CGFloat(idx)
        }
    }

    // MARK: Dimming (alpha-based)

    private func setLeftPageAlpha(_ alpha: CGFloat) {
        guard let state = interaction else { return }
        controllers[state.leftIndex].view.alpha = alpha
    }

    private func alphaForProgress(_ progress: CGFloat, direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .left:
            return 1 - (1 - minimumAlpha) * progress
        case .right:
            return minimumAlpha + (1 - minimumAlpha) * progress
        }
    }

    // MARK: External Control

    func setCurrentIndex(_ index: Int, animated: Bool) {
        guard index != currentIndex,
              controllers.indices.contains(index) else { return }

        guard animated else {
            jumpToIndex(index)
            return
        }

        cancelCurrentInteraction()
        animateToIndex(index)
    }

    private func jumpToIndex(_ index: Int) {
        resetAllViews(activeIndex: index)
        currentIndex = index
    }

    private func animateToIndex(_ index: Int) {
        let direction: SwipeDirection = index > currentIndex ? .left : .right
        let leftIndex = min(currentIndex, index)

        interaction = InteractionState(direction: direction, targetIndex: index, leftIndex: leftIndex)

        let (currentVC, targetVC) = (controllers[currentIndex], controllers[index])
        let width = view.bounds.width

        prepareViewsForTransition(currentVC: currentVC, targetVC: targetVC, direction: direction)

        let anim = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timingParameters)
        anim.addAnimations {
            self.applyFinalTransforms(currentVC: currentVC, targetVC: targetVC, direction: direction, width: width)
            self.setLeftPageAlpha(self.alphaForProgress(1, direction: direction))
        }
        anim.addCompletion { _ in
            self.finishTransition(toIndex: index)
            self.cleanup()
        }
        anim.startAnimation()
    }

    // MARK: Gesture Handling

    private var panStartX: CGFloat = 0

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).x
        let width = view.bounds.width

        switch gesture.state {
        case .began:
            panStartX = gesture.location(in: view).x

        case .changed:
            handlePanChanged(translation: translation, width: width)

        case .ended, .cancelled:
            if interaction != nil {
                finishInteraction(translation: translation, width: width, velocity: gesture.velocity(in: view).x)
            }

        default:
            break
        }
    }

    private func handlePanChanged(translation: CGFloat, width: CGFloat) {
        if interaction == nil {
            guard let (direction, targetIndex) = determineSwipeTarget(translation: translation, width: width) else { return }
            beginTransition(to: targetIndex, direction: direction)
        }

        guard let state = interaction else { return }

        let progress = min(max(abs(translation) / width, 0), 1)
        animator?.fractionComplete = progress
        setLeftPageAlpha(alphaForProgress(progress, direction: state.direction))
    }

    private func determineSwipeTarget(translation: CGFloat, width: CGFloat) -> (SwipeDirection, Int)? {
        guard abs(translation) > 0 else { return nil }

        let fromLeftEdge = panStartX < width * swipeEdgeThreshold
        let fromRightEdge = panStartX > width * (1 - swipeEdgeThreshold)

        if translation > 0, fromLeftEdge, currentIndex > 0 {
            return (.right, currentIndex - 1)
        } else if translation < 0, fromRightEdge, currentIndex < controllers.count - 1 {
            return (.left, currentIndex + 1)
        }

        return nil
    }

    private func beginTransition(to targetIndex: Int, direction: SwipeDirection) {
        let leftIndex = min(currentIndex, targetIndex)
        interaction = InteractionState(direction: direction, targetIndex: targetIndex, leftIndex: leftIndex)

        let (currentVC, targetVC) = (controllers[currentIndex], controllers[targetIndex])
        let width = view.bounds.width

        prepareViewsForTransition(currentVC: currentVC, targetVC: targetVC, direction: direction)

        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timingParameters)
        animator?.addAnimations { [weak self] in
            self?.applyFinalTransforms(currentVC: currentVC, targetVC: targetVC, direction: direction, width: width)
        }
        animator?.pauseAnimation()
        animator?.addCompletion { [weak self] position in
            self?.completeTransition(position: position)
        }
    }

    private func prepareViewsForTransition(currentVC: UIViewController, targetVC: UIViewController, direction: SwipeDirection) {
        let width = view.bounds.width
        let leftIndex = min(currentIndex, interaction?.targetIndex ?? currentIndex)
        let rightIndex = max(currentIndex, interaction?.targetIndex ?? currentIndex)

        let leftVC = controllers[leftIndex]
        let rightVC = controllers[rightIndex]

        currentVC.view.isHidden = false
        targetVC.view.isHidden = false

        leftVC.view.layer.zPosition = 0
        rightVC.view.layer.zPosition = 1

        leftVC.view.alpha = direction == .left ? 1 : minimumAlpha
        rightVC.view.alpha = 1

        switch direction {
        case .left:
            targetVC.view.transform = CGAffineTransform(translationX: width, y: 0)
            currentVC.view.transform = .identity
        case .right:
            targetVC.view.transform = CGAffineTransform(translationX: -width * parallaxAmount, y: 0)
            currentVC.view.transform = .identity
        }

        [currentVC, targetVC].forEach { $0.view.clearShadow() }
        rightVC.view.applyShadow()

        // Apply mask to top page during transition (evaluated in SwiftUI context)
        applyTransitionMask(toPageAt: rightIndex)
    }

    // MARK: - Transition Masking

    private func applyTransitionMask(toPageAt index: Int) {
        guard maskStates.indices.contains(index) else { return }
        maskStates[index].isApplied = true
    }

    private func removeAllTransitionMasks() {
        for state in maskStates {
            state.isApplied = false
        }
    }

    private func applyFinalTransforms(currentVC: UIViewController, targetVC: UIViewController, direction: SwipeDirection, width: CGFloat) {
        switch direction {
        case .left:
            currentVC.view.transform = CGAffineTransform(translationX: -width * parallaxAmount, y: 0)
            targetVC.view.transform = .identity
        case .right:
            currentVC.view.transform = CGAffineTransform(translationX: width, y: 0)
            targetVC.view.transform = .identity
        }
    }

    private func finishInteraction(translation: CGFloat, width: CGFloat, velocity: CGFloat) {
        guard var state = interaction, let animator = animator else { return }

        let progress = min(max(abs(translation) / width, 0), 1)
        let shouldComplete = progress > 0.5 || abs(velocity) > 500

        state.completingToTarget = shouldComplete
        interaction = state

        animator.isReversed = !shouldComplete

        let finalAlpha = shouldComplete
            ? alphaForProgress(1, direction: state.direction)
            : alphaForProgress(0, direction: state.direction)

        let remaining = shouldComplete ? 1 - progress : progress
        let duration = animationDuration * max(0.2, remaining)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.setLeftPageAlpha(finalAlpha)
        }

        animator.continueAnimation(withTimingParameters: nil, durationFactor: max(0.2, remaining))
    }

    private func completeTransition(position: UIViewAnimatingPosition) {
        guard let state = interaction else {
            resetToCurrent()
            return
        }

        if state.completingToTarget, position == .end {
            finishTransition(toIndex: state.targetIndex)
        } else {
            revertTransition()
        }

        cleanup()
    }

    private func finishTransition(toIndex index: Int) {
        resetAllViews(activeIndex: index)
        currentIndex = index
    }

    private func revertTransition() {
        resetAllViews(activeIndex: currentIndex)
    }

    private func resetToCurrent() {
        resetAllViews(activeIndex: currentIndex)
        cleanup()
    }

    private func resetAllViews(activeIndex: Int) {
        removeAllTransitionMasks()

        for (idx, vc) in controllers.enumerated() {
            vc.view.isHidden = idx != activeIndex
            vc.view.transform = .identity
            vc.view.alpha = 1.0
            vc.view.clearShadow()
        }
        controllers[activeIndex].view.applyShadow()
        reorderViewStack()
    }

    private func cancelCurrentInteraction() {
        animator?.stopAnimation(true)
        animator = nil
        interaction = nil
    }

    private func cleanup() {
        animator = nil
        interaction = nil
        reorderViewStack()
    }
}

// MARK: - UIView Helpers

private extension UIView {
    func applyShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
    }

    func clearShadow() {
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var page = 1

    ParallaxPageView(page: $page, maskShape: ContainerRelativeShape()) {
        Color.pink
            .ignoresSafeArea()
            .overlay(
                Text("Page \(page + 1)")
                    .font(.largeTitle).foregroundStyle(.white)
            )

        TabView {
            Tab("Received", systemImage: "tray.and.arrow.down.fill") {
                Text("Page \(page + 1)")
                    .tag(0)
            }
            .badge(2)

            Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
                Text("sent")
                    .tag(1)
            }

            Tab("Account", systemImage: "person.crop.circle.fill") {
                Text("account")
                    .tag(2)
            }
            .badge("!")
        }

        NavigationStack {
            Color.orange
                .overlay(
                    Text("Page \(page + 1)")
                        .font(.largeTitle).foregroundStyle(.white)
                )
                .navigationTitle("Title")
        }
    }
    .task {
        try? await Task.sleep(for: .seconds(2))
        page = 0
    }
}
