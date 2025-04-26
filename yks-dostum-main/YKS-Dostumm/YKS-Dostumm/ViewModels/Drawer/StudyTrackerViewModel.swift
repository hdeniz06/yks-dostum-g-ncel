import Foundation
import Combine

class StudyTrackerViewModel: ObservableObject {
    @Published var sessions: [StudySession] = []
    @Published var badges: [Badge] = []
    @Published var selectedTopic: String = ""
    @Published var timerRunning: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var showBadge: Bool = false
    @Published var earnedBadge: Badge? = nil
    
    private var timer: AnyCancellable?
    private var startDate: Date?
    private let topics = ["Matematik", "Fizik", "Kimya", "Biyoloji", "Tarih", "Coğrafya", "Edebiyat"]
    
    func availableTopics() -> [String] {
        topics
    }
    
    func startSession(topic: String, targetMinutes: Int) {
        selectedTopic = topic
        elapsedTime = 0
        timerRunning = true
        startDate = Date()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedTime += 1
                self.progress = min(self.elapsedTime / (Double(targetMinutes) * 60), 1.0)
                if self.progress >= 1.0 {
                    self.finishSession()
                }
            }
    }
    
    func pauseSession() {
        timer?.cancel()
        timerRunning = false
    }
    
    func finishSession() {
        timer?.cancel()
        timerRunning = false
        let session = StudySession(topic: selectedTopic, targetDuration: progress * 60 * 60, completedDuration: elapsedTime, date: startDate ?? Date())
        sessions.append(session)
        checkForBadge(session: session)
    }
    
    private func checkForBadge(session: StudySession) {
        // Basit örnek: 1 saat tamamlanınca rozet
        if session.completedDuration >= 3600 {
            let badge = Badge(name: "1 Saat Kahramanı", description: "Bir oturumda 1 saat çalıştın!")
            badges.append(badge)
            earnedBadge = badge
            showBadge = true
        }
    }
}
