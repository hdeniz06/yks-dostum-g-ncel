import Foundation
import SwiftUI
import Combine


class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isTyping: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let geminiService: GeminiService
    
    init() {
        // MARK: Gemini API anahtarınızı buraya ekleyin
        // Not: Bu sadece geliştirme amaçlıdır. Uygulama yayınlanmadan önce daha güvenli bir yaklaşım kullanın
        let apiKey = "AIzaSyDGT4zE3EEqDDcK0f0KEHW-NHJ741akjGo"
        self.geminiService = GeminiService(apiKey: apiKey)
        loadInitialMessages()
    }
    
    private func loadInitialMessages() {
        let welcomeMessage = ChatMessage(
            id: UUID(),
            sender: .assistant,
            content: "Merhaba! Ben YKS Asistanın. Sana YKS hazırlık sürecinde yardımcı olmak için buradayım. Ders çalışma teknikleri, konu anlatımı, soru çözümü veya motivasyon konularında sorularını yanıtlayabilirim. Nasıl yardımcı olabilirim?",
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            sender: .user,
            content: inputText,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input and store message
        let userInput = inputText
        inputText = ""
        
        // Set AI thinking state
        isTyping = true
        
        print("Sending message to ChatGPT: \(userInput.prefix(30))...")
        
        // Cancel any existing requests
        cancellables.removeAll()
        
        // Call Gemini API
        geminiService.generateResponse(prompt: userInput)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error generating response: \(error.localizedDescription)")
                    self?.handleAPIError(error)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                print("Received successful response from Gemini")
                
                // Add AI response
                let assistantMessage = ChatMessage(
                    id: UUID(),
                    sender: .assistant,
                    content: response,
                    timestamp: Date()
                )
                self.messages.append(assistantMessage)
                self.isTyping = false
            })
            .store(in: &cancellables)
    }
    
    private func handleAPIError(_ error: Error? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var errorContent = "Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin."
            
            if let error = error {
                print("API error details: \(error.localizedDescription)")
                
                if let nsError = error as NSError? {
                    if nsError.domain == NSURLErrorDomain {
                        switch nsError.code {
                        case NSURLErrorNotConnectedToInternet:
                            errorContent = "İnternet bağlantınızı kontrol edin ve tekrar deneyin."
                        case NSURLErrorTimedOut:
                            errorContent = "İstek zaman aşımına uğradı. Lütfen tekrar deneyin."
                        default:
                            errorContent = "Bir hata oluştu (\(nsError.code)). Lütfen tekrar deneyin."
                        }
                    }
                }
            }
            
            let errorMessage = ChatMessage(
                id: UUID(),
                sender: .assistant,
                content: errorContent,
                timestamp: Date()
            )
            self.messages.append(errorMessage)
            self.isTyping = false
        }
    }
}

// MARK: - Message Models
enum MessageSender {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    var id: UUID
    var sender: MessageSender
    var content: String
    var timestamp: Date
}
