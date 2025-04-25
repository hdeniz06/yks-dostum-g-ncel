import Foundation
import Combine

protocol BaseViewModel: ObservableObject {
    // Common properties and methods for all ViewModels
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
}

class BaseViewModelImpl: BaseViewModel {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
}
