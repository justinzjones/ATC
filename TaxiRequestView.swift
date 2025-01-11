private func validateReadback() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        guard let response = controllerResponse else { return }
        isReadbackCorrect = TaxiInstruction.validateReadback(selectedReadbackElements, controllerResponse: response.elements)
        if isReadbackCorrect {
            readbackFeedback = nil  // Clear any existing feedback
            isControllerResponseExpanded = false
            isReadbackExpanded = false
        } else {
            readbackFeedback = "Incorrect readback. Please try again and ensure you include all required elements."
        }
    }
} 