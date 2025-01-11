struct ExerciseCommunication {
    let stepNumber: Int
    let situationText: String
    let pilotRequest: String?
    let atcResponse: String?
    let pilotReadback: String?
    
    init(from scenario: TrainingScenario) {
        self.stepNumber = scenario.stepNumber
        self.situationText = scenario.situationText
        self.pilotRequest = scenario.pilotRequest
        self.atcResponse = scenario.atcResponse
        self.pilotReadback = scenario.pilotReadback
    }
} 