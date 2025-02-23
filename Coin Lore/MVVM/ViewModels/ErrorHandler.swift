import Foundation

class ErrorHandler: ObservableObject {
    @Published var currentError: Error?

    func setError(_ error: Error) {
        self.currentError = error
    }

    func clearError() {
        self.currentError = nil
    }
}
