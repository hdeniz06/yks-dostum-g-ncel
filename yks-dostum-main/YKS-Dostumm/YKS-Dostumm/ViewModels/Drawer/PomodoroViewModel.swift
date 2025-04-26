import Foundation
import Combine
import SwiftUI
import UserNotifications

class PomodoroViewModel: ObservableObject {
    // Durations
    let initialWorkDuration: TimeInterval
    let initialShortBreakDuration: TimeInterval
    let initialLongBreakDuration: TimeInterval
    let sessionsBeforeLongBreak: Int

    // Published state
    @Published var currentPhase: Phase = .work
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var completedSessions: Int = 0

    private var timer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()

    enum Phase {
        case work, shortBreak, longBreak

        var color: Color {
            switch self {
            case .work: return .red
            case .shortBreak: return .green
            case .longBreak: return .purple
            }
        }
    }

    init(workDuration: TimeInterval = 25 * 60,
         shortBreakDuration: TimeInterval = 5 * 60,
         longBreakDuration: TimeInterval = 15 * 60,
         sessionsBeforeLongBreak: Int = 4) {
        self.initialWorkDuration = workDuration
        self.initialShortBreakDuration = shortBreakDuration
        self.initialLongBreakDuration = longBreakDuration
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.timeRemaining = workDuration
        requestNotificationPermission()
    }

    var workDuration: TimeInterval
    var shortBreakDuration: TimeInterval
    var longBreakDuration: TimeInterval

    var currentPhaseDuration: TimeInterval {
        switch currentPhase {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    var progress: Double {
        guard currentPhaseDuration > 0 else { return 0 }
        return 1 - (timeRemaining / currentPhaseDuration)
    }

    var currentPhaseText: String {
        switch currentPhase {
        case .work: return "Çalışma Zamanı"
        case .shortBreak: return "Kısa Mola"
        case .longBreak: return "Uzun Mola"
        }
    }

    var phaseColor: Color { currentPhase.color }

    var completedSessionsModCycle: Int {
        guard sessionsBeforeLongBreak > 0 else { return completedSessions }
        return completedSessions % sessionsBeforeLongBreak
    }

    func updateSettings(workDuration: TimeInterval, shortBreakDuration: TimeInterval, longBreakDuration: TimeInterval = 15 * 60) {
        self.timeRemaining = workDuration
        
        // Store new values
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        
        // Reset to work phase
        self.currentPhase = .work
    }

    func startPause() {
        isRunning ? pause() : start()
    }

    func start() {
        isRunning = true
        scheduleNotification()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        currentPhase = .work
        timeRemaining = initialWorkDuration
        completedSessions = 0
    }

    func skipPhase() {
        timer?.invalidate()
        nextPhase()
        if isRunning { start() }
    }

    private func tick() {
        guard timeRemaining > 0 else {
            completePhase()
            return
        }
        timeRemaining -= 1
    }

    private func completePhase() {
        timer?.invalidate()
        if currentPhase == .work {
            completedSessions += 1
        }
        nextPhase()
        if isRunning { start() }
        sendNotification()
    }

    private func nextPhase() {
        if currentPhase == .work {
            if completedSessions % sessionsBeforeLongBreak == 0 && completedSessions > 0 {
                currentPhase = .longBreak
                timeRemaining = longBreakDuration
            } else {
                currentPhase = .shortBreak
                timeRemaining = shortBreakDuration
            }
        } else {
            currentPhase = .work
            timeRemaining = workDuration
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        notificationCenter.add(request)
    }

    private var notificationTitle: String {
        switch currentPhase {
        case .work: return "Çalışma Tamamlandı"
        case .shortBreak: return "Kısa Mola Bitti"
        case .longBreak: return "Uzun Mola Bitti"
        }
    }

    private var notificationBody: String {
        switch currentPhase {
        case .work: return "Zaman doldu. Mola zamanı!"
        case .shortBreak, .longBreak: return "Mola tamamlandı. Çalışmaya devam et!"
        }
    }

    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle errors if needed
        }
    }
}

extension TimeInterval {
    func formattedTime() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
