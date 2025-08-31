import SwiftUI

@Observable final class StepSliderViewModel<V: Hashable> {
    var steps: [StepSlider<V>.Step]
    var currentStep: StepSlider<V>.Step?
    var stepPosition: [UUID: CGFloat] = [:]

    init(steps: [StepSlider<V>.Step]) {
        self.steps = steps
    }
}

extension StepSliderViewModel {
    func recordPosition(for step: StepSlider<V>.Step, at position: CGFloat) {
        stepPosition[step.id] = position
    }

    func position(for step: StepSlider<V>.Step) -> CGFloat? {
        stepPosition[step.id]
    }

    func positionForFirstStep() -> CGFloat? {
        if let step = firstStep() {
            return position(for: step)
        }
        return nil
    }

    func positionForLastStep() -> CGFloat? {
        if let step = lastStep() {
            return position(for: step)
        }
        return nil
    }
}

extension StepSliderViewModel {
    func step(before currentStep: StepSlider<V>.Step) -> StepSlider<V>.Step? {
        guard let currentIndex = steps.firstIndex(of: currentStep), currentIndex > 0 else {
            return nil
        }
        return steps[currentIndex - 1]
    }

    func step(after currentStep: StepSlider<V>.Step) -> StepSlider<V>.Step? {
        guard let currentIndex = steps.firstIndex(of: currentStep), currentIndex < steps.count - 1 else {
            return nil
        }
        return steps[currentIndex + 1]
    }

    func lastStep() -> StepSlider<V>.Step? {
        steps.last
    }

    func firstStep() -> StepSlider<V>.Step? {
        steps.first
    }
}
