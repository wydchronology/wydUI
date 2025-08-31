import OrderedCollections
import SwiftUI

struct StepSlider<V: Hashable>: View {
    var viewModel: StepSliderViewModel<V>

    var size: CGFloat = .defaultIconSize
    var foregroundStyle: Color = .invertedForegroundPrimary

    @GestureState private var dragInfo: DragInfo = .inactive
    @State private var stepsPassedDuringTranslation: OrderedSet<Step> = []

    var onChange: ((StepSlider<V>.Step) -> Void)? = nil

    var body: some View {
        SliderView()
    }

    @ViewBuilder private func SliderView() -> some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(viewModel.steps, id: \.id) { step in
                    Color.clear.onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.frame(in: .global).origin.x
                    } action: { position in
                        viewModel.recordPosition(for: step, at: position)
                    }
                    .frame(width: 0, height: 0)
                    Spacer()
                    SliderItem(step: step)
                    Spacer()
                }
            }
            .coordinateSpace(name: "slider")
            .padding(.paddingNormal)

            LabelAndDescription()
                .padding(.paddingNormal)
        }
    }

    @ViewBuilder private func LabelAndDescription() -> some View {
        VStack {
            Text(labelForFurthestPassedStepOrCurrent())
                .font(.system(.headline, design: .rounded, weight: .medium))
                .foregroundStyle(Color.label)

            Text(descriptionForFurthestPassedStepOrCurrent())
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(Color.secondaryLabel)
        }
    }

    @ViewBuilder private func SliderItem(step: Step) -> some View {
        Button(action: {
            viewModel.currentStep = step
        }) {
            ImageView(step: step)
                .offset(x: dragInfo.step.id == step.id ? dragInfo.translation : 0)
                .animation(.interpolatingSpring(), value: dragInfo.translation)
                .gesture(
                    DragGesture(coordinateSpace: .named("slider"))
                        .updating($dragInfo) { value, state, _ in
                            if step.id == viewModel.currentStep?.id {
                                let minPosition: CGFloat = viewModel.positionForFirstStep() ?? 0
                                let maxPosition: CGFloat = viewModel.positionForLastStep() ?? 0
                                let translation = value.location.x - value.startLocation.x
                                let minTranslation = minPosition + (size * 0.75) - value.startLocation.x
                                let maxTranslation = maxPosition + (size * 0.75) - value.startLocation.x

                                let didPassFirstStep = translation < minTranslation
                                let didPassLastStep = translation > maxTranslation

                                if didPassFirstStep {
                                    state = .active(translation: minTranslation, step: step, start: value.startLocation.x)
                                } else if didPassLastStep {
                                    state = .active(translation: maxTranslation, step: step, start: value.startLocation.x)
                                } else {
                                    state = .active(translation: translation, step: step, start: value.startLocation.x)
                                }

                                stepsPassedDuringTranslation = findStepsPassed(startingAt: step)
                            }
                        }
                        .onEnded { _ in
                            // set current step to the furthest passed step
                            if let nextStep = furthestPassedStep(startingAt: step) {
                                viewModel.currentStep = nextStep
                                onChange?(nextStep)
                            }

                            // reset steps passed during translation
                            stepsPassedDuringTranslation = []
                        }
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: viewModel.currentStep)
    }

    @ViewBuilder private func ImageViewContentView(step: Step) -> some View {
        Image(systemName: imageFor(step: step))
            .resizable()
            .scaledToFit()
            .contentTransition(.symbolEffect(.replace))
            .foregroundStyle(step.id == viewModel.currentStep?.id ? foregroundStyle : Color.foregroundPrimary)
            .frame(width: size, height: size)
            .padding(.paddingNormal)
            .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: stepsPassedDuringTranslation.contains(step))
            .sensoryFeedback(.levelChange, trigger: dragInfo.translation)
            .phaseAnimator(AnimationPhase.allCases, trigger: stepsPassedDuringTranslation.contains(step)) { content, phase in
                content
                    .scaleEffect(phase.scaleEffect)
                    .offset(y: phase.verticalOffset)
            } animation: { phase in
                switch phase {
                case .move: .interactiveSpring(duration: 0.3)
                case .scale: .interpolatingSpring(duration: 0.3)
                case .initial: .easeIn
                }
            }
    }

    @ViewBuilder private func ImageView(step: Step) -> some View {
        if #available(iOS 26, *) {
            ImageViewContentView(step: step)
                .background(step.id == viewModel.currentStep?.id ? Color.systemFill : Color.tertiarySystemFill)
                .clipShape(Circle())
                .glassEffect(
                    .clear.tint(
                        step.id == viewModel.currentStep?.id ? Color.surfacePrimary : Color.clear
                    ).interactive(),
                    in: Circle()
                )

        } else {
            ImageViewContentView(step: step)
                .background(step.id == viewModel.currentStep?.id ? Color.quaternarySystemFill : Color.clear)
                .clipShape(Circle())
        }
    }

    func imageFor(step: Step) -> String {
        if step.id == dragInfo.step.id {
            ""
        } else if step.id == viewModel.currentStep?.id {
            step.activeImage
        } else {
            step.inactiveImage
        }
    }

    func labelForFurthestPassedStepOrCurrent() -> String {
        furthestPassedStep(startingAt: dragInfo.step)?.label ?? viewModel.currentStep?.label ?? ""
    }

    func descriptionForFurthestPassedStepOrCurrent() -> String {
        furthestPassedStep(startingAt: dragInfo.step)?.description ?? viewModel.currentStep?.description ?? ""
    }

    func furthestPassedStep(startingAt _: Step) -> Step? {
        stepsPassedDuringTranslation.reversed().first
    }

    func findStepsPassed(startingAt step: Step) -> OrderedSet<Step> {
        var stepsPassed: OrderedSet<Step> = []

        let dragPosition = dragInfo.translation + dragInfo.start

        if dragInfo.translation < 0 {
            // search for closest previous step
            var prevStep = viewModel.step(before: step)
            while prevStep != nil {
                if let prevStepPosition = viewModel.position(for: prevStep!) {
                    if dragPosition < prevStepPosition + size {
                        stepsPassed.insert(prevStep!, at: stepsPassed.count)
                    }
                }
                prevStep = viewModel.step(before: prevStep!)
            }
        } else {
            // search for closest next step
            var nextStep = viewModel.step(after: step)
            while nextStep != nil {
                if let nextStepPosition = viewModel.position(for: nextStep!) {
                    if dragPosition > nextStepPosition {
                        stepsPassed.insert(nextStep!, at: stepsPassed.count)
                    }
                }

                nextStep = viewModel.step(after: nextStep!)
            }
        }

        return stepsPassed
    }
}

#Preview("StepSlider") {
    @Previewable @State var stepViewModel = StepSliderViewModel<String>(
        steps: [
            StepSlider.Step(
                label: "Private",
                description: "Only you can see this",
                inactiveImage: "lock",
                activeImage: "lock.fill",
                value: EventVisibility.privateVisibility.rawValue
            ),
            StepSlider.Step(
                label: "Friends",
                description: "Only your friends can see this",
                inactiveImage: "person.2.wave.2",
                activeImage: "person.2.wave.2.fill",
                value: EventVisibility.mutualsVisibility.rawValue
            ),
            StepSlider.Step(
                label: "Guests only",
                description: "Anyone with an invitation",
                inactiveImage: "lock.open",
                activeImage: "lock.open.fill",
                value: EventVisibility.publicVisibility.rawValue
            ),
            StepSlider.Step(
                label: "Public",
                description: "Anyone can see this",
                inactiveImage: "globe",
                activeImage: "globe",
                value: EventVisibility.publicVisibility.rawValue
            ),
        ]
    )

    StepSlider(viewModel: stepViewModel)
        .task {
            stepViewModel.currentStep = stepViewModel.steps.first
        }
        .padding()
}
