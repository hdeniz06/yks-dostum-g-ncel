import Foundation
import Combine
import SwiftUI
import UserNotifications

class TimersViewModel: ObservableObject {
    // Arka plan zamanlayıcı yöneticisi
    private var backgroundManager: TimerBackgroundManager?
    // MARK: - Pomodoro Özellikleri
    @Published var pomodoroTimers: [PomodoroTimer] = []
    @Published var selectedPomodoroTimer: PomodoroTimer?
    @Published var currentPomodoroState: TimerState = .stopped
    @Published var currentPhase: PomodoroPhase = .work
    @Published var timeRemaining: TimeInterval = 0
    @Published var completedSessions: Int = 0
    @Published var totalWorkTime: TimeInterval = 0
    @Published var totalCompletedSessions: Int = 0
    
    // Geri sayım zamanlayıcıları
    @Published var countdownTimers: [CountdownTimer] = []
    
    // YKS sınavına kalan süre
    @Published var yksExamDate: Date
    
    // Genel
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var pomodoroTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    init() {
        // YKS sınav tarihini ayarla (örnek: 17 Haziran 2026)
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        self.yksExamDate = calendar.date(from: dateComponents) ?? Date().addingTimeInterval(86400 * 365) // 1 yıl sonra
        
        loadTimers()
        setupNotifications()
        startBackgroundUpdates()
        
        // Arka plan yöneticisini oluştur
        self.backgroundManager = TimerBackgroundManager()
    }
    
    // MARK: - Timer Yönetimi
    
    func loadTimers() {
        isLoading = true
        
        // Pomodoro zamanlayıcılarını yükle
        if let pomodoroData = userDefaults.data(forKey: "pomodoroTimers") {
            do {
                let decodedTimers = try JSONDecoder().decode([PomodoroTimer].self, from: pomodoroData)
                self.pomodoroTimers = decodedTimers
            } catch {
                self.errorMessage = "Pomodoro zamanlayıcıları yüklenemedi: \(error.localizedDescription)"
            }
        } else {
            // Varsayılan bir pomodoro zamanlayıcısı ekle
            let defaultTimer = PomodoroTimer(name: "Standart Pomodoro")
            self.pomodoroTimers.append(defaultTimer)
            saveTimers()
        }
        
        // Geri sayım zamanlayıcılarını yükle
        if let countdownData = userDefaults.data(forKey: "countdownTimers") {
            do {
                let decodedTimers = try JSONDecoder().decode([CountdownTimer].self, from: countdownData)
                self.countdownTimers = decodedTimers
            } catch {
                self.errorMessage = "Geri sayım zamanlayıcıları yüklenemedi: \(error.localizedDescription)"
            }
        }
        
        // Pomodoro durumunu yükle
        if let stateData = userDefaults.data(forKey: "pomodoroState") {
            do {
                let state = try JSONDecoder().decode(PomodoroState.self, from: stateData)
                self.currentPomodoroState = state.timerState
                self.currentPhase = state.phase
                self.timeRemaining = state.timeRemaining
                self.completedSessions = state.completedSessions
                self.totalWorkTime = state.totalWorkTime
                self.totalCompletedSessions = state.totalCompletedSessions
                
                if let timerId = state.selectedTimerId,
                   let timer = pomodoroTimers.first(where: { $0.id == timerId }) {
                    self.selectedPomodoroTimer = timer
                    if state.timerState == .running {
                        startTimer()
                    }
                }
            } catch {
                self.errorMessage = "Pomodoro durumu yüklenemedi: \(error.localizedDescription)"
            }
        } else {
            // YKS sınavı için varsayılan bir geri sayım ekle
            let yksCountdown = CountdownTimer(name: "YKS Sınavına Kalan Süre", targetDate: yksExamDate, color: .blue)
            self.countdownTimers.append(yksCountdown)
            saveTimers()
        }
        
        isLoading = false
    }
    
    func saveTimers() {
        do {
            let pomodoroData = try JSONEncoder().encode(pomodoroTimers)
            userDefaults.set(pomodoroData, forKey: "pomodoroTimers")
            
            let countdownData = try JSONEncoder().encode(countdownTimers)
            userDefaults.set(countdownData, forKey: "countdownTimers")
        } catch {
            self.errorMessage = "Zamanlayıcılar kaydedilemedi: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Pomodoro İşlemleri
    
    func addPomodoroTimer(_ timer: PomodoroTimer) {
        pomodoroTimers.append(timer)
        saveTimers()
    }
    
    func addPomodoroTimer(name: String, workDuration: TimeInterval, breakDuration: TimeInterval, longBreakDuration: TimeInterval, sessionsBeforeLongBreak: Int) {
        let newTimer = PomodoroTimer(
            name: name,
            workDuration: workDuration,
            breakDuration: breakDuration,
            longBreakDuration: longBreakDuration,
            sessionsBeforeLongBreak: sessionsBeforeLongBreak
        )
        
        pomodoroTimers.append(newTimer)
        saveTimers()
    }
    
    func deletePomodoroTimer(at indexSet: IndexSet) {
        pomodoroTimers.remove(atOffsets: indexSet)
        saveTimers()
    }
    
    func selectPomodoroTimer(_ timer: PomodoroTimer) {
        stopPomodoro()
        selectedPomodoroTimer = timer
        resetPomodoro()
    }
    
    func startPomodoro() {
        guard let selectedTimer = selectedPomodoroTimer else { return }
        
        if currentPomodoroState == .paused {
            // Duraklatılmış zamanlayıcıyı devam ettir
            resumePomodoro()
            return
        }
        
        // Yeni bir pomodoro başlat
        currentPomodoroState = .running
        currentPhase = .work
        timeRemaining = selectedTimer.workDuration
        startTimer()
        savePomodoroState()
        
        // Bildirim planla
        let content = UNMutableNotificationContent()
        content.title = "Çalışma Süresi Bitti"
        content.body = "Tebrikler! Çalışma süreniz tamamlandı. Mola zamanı."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_\(selectedTimer.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func pausePomodoro() {
        currentPomodoroState = .paused
        pomodoroTimer?.invalidate()
        savePomodoroState()
    }
    
    func resumePomodoro() {
        currentPomodoroState = .running
        startTimer()
        savePomodoroState()
    }
    
    func stopPomodoro() {
        currentPomodoroState = .stopped
        pomodoroTimer?.invalidate()
        resetPomodoro()
    }
    
    func resetPomodoro() {
        pomodoroTimer?.invalidate()
        currentPomodoroState = .stopped
        timeRemaining = 0
        completedSessions = 0
        currentPhase = .work
    }
    
    func resetStats() {
        // Pomodoro istatistiklerini sıfırla
        totalWorkTime = 0
        totalCompletedSessions = 0
        completedSessions = 0
        timeRemaining = selectedPomodoroTimer?.workDuration ?? 0
        currentPhase = .work
        currentPomodoroState = .stopped
        pomodoroTimer?.invalidate()
        
        // Bildirimleri temizle
        if let timer = selectedPomodoroTimer {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro_\(timer.id)"])
            backgroundManager?.removeTimer(id: "pomodoro_\(timer.id)")
        }
        
        saveTimers()
        savePomodoroState()
    }
    
    func skipToNextPhase() {
        // Eğer zamanlayıcı çalışmıyorsa bir şey yapma
        guard currentPomodoroState != .stopped, let timer = selectedPomodoroTimer else { return }
        
        // Mevcut fazı tamamla ve bir sonraki faza geç
        switch currentPhase {
        case .work:
            // Çalışma fazını tamamla, toplam çalışma süresine ekle
            if timer.workDuration - timeRemaining > 0 {
                totalWorkTime += (timer.workDuration - timeRemaining)
            }
            
            // Tamamlanan seans sayısını kontrol et
            completedSessions += 1
            totalCompletedSessions += 1
            
            // Uzun mola zamanı mı?
            if completedSessions >= timer.sessionsBeforeLongBreak {
                currentPhase = .longBreak
                timeRemaining = timer.longBreakDuration
                completedSessions = 0
            } else {
                currentPhase = .break
                timeRemaining = timer.breakDuration
            }
            
        case .break, .longBreak:
            // Molayı atla ve çalışmaya başla
            currentPhase = .work
            timeRemaining = timer.workDuration
        }
        
        // Zamanlayıcıyı güncelle
        if currentPomodoroState == .running {
            pomodoroTimer?.invalidate()
            startTimer()
        }
        scheduleNotification()
        savePomodoroState()
    }
    
    private func updatePomodoroTimer() {
        guard currentPomodoroState == .running, timeRemaining > 0 else {
            if currentPomodoroState == .running {
                // Zamanlayıcı tamamlandı, sonraki aşamaya geç
                completeCurrentPomodoroPhase()
            }
            return
        }
        
        timeRemaining -= 1
        savePomodoroState()
    }
    
    private func completeCurrentPomodoroPhase() {
        guard let selectedTimer = selectedPomodoroTimer else { return }
        
        switch currentPhase {
        case .work:
            // Çalışma aşaması tamamlandı
            completedSessions += 1
            totalCompletedSessions += 1
            
            // Toplam çalışma süresini güncelle
            totalWorkTime += selectedTimer.workDuration
            
            // Bildirim gönder
            sendNotification(title: "Çalışma Süresi Bitti", body: "Tebrikler! Çalışma süreniz tamamlandı. Mola zamanı.")
            
            // Uzun mola zamanı mı?
            if completedSessions >= selectedTimer.sessionsBeforeLongBreak {
                currentPhase = .longBreak
                timeRemaining = selectedTimer.longBreakDuration
                completedSessions = 0
            } else {
                currentPhase = .break
                timeRemaining = selectedTimer.breakDuration
            }
            
        case .break:
            // Kısa mola tamamlandı
            currentPhase = .work
            timeRemaining = selectedTimer.workDuration
            
            // Bildirim gönder
            sendNotification(title: "Mola Bitti", body: "Molanız bitti. Çalışmaya devam etme zamanı!")
            
        case .longBreak:
            // Uzun mola tamamlandı
            currentPhase = .work
            timeRemaining = selectedTimer.workDuration
            
            // Bildirim gönder
            sendNotification(title: "Uzun Mola Bitti", body: "Uzun molanız bitti. Çalışmaya devam etme zamanı!")
        }
    }
    
    // MARK: - Geri Sayım İşlemleri
    
    func addCountdownTimer(_ timer: CountdownTimer) {
        countdownTimers.append(timer)
        saveTimers()
        
        // Arka plan desteği için zamanlayıcıyı kaydet
        backgroundManager?.addTimer(id: "countdown_\(timer.id.uuidString)", endTime: timer.targetDate)
    }
    
    func addCountdownTimer(name: String, targetDate: Date, color: Color) {
        let newTimer = CountdownTimer(name: name, targetDate: targetDate, color: color)
        countdownTimers.append(newTimer)
        saveTimers()
        
        // Arka plan desteği için zamanlayıcıyı kaydet
        backgroundManager?.addTimer(id: "countdown_\(newTimer.id.uuidString)", endTime: targetDate)
    }
    
    func deleteCountdownTimer(at indexSet: IndexSet) {
        countdownTimers.remove(atOffsets: indexSet)
        saveTimers()
    }
    
    func updateCountdownTimer(_ timer: CountdownTimer) {
        if let index = countdownTimers.firstIndex(where: { $0.id == timer.id }) {
            countdownTimers[index] = timer
            saveTimers()
        }
    }
    
    // MARK: - Pomodoro Durumu Yönetimi
    
    private func savePomodoroState() {
        let state = PomodoroState(
            timerState: currentPomodoroState,
            phase: currentPhase,
            timeRemaining: timeRemaining,
            completedSessions: completedSessions,
            totalWorkTime: totalWorkTime,
            totalCompletedSessions: totalCompletedSessions,
            selectedTimerId: selectedPomodoroTimer?.id
        )
        
        do {
            let data = try JSONEncoder().encode(state)
            userDefaults.set(data, forKey: "pomodoroState")
            userDefaults.synchronize()
            
            // Arka plan zamanlayıcısını güncelle
            if let timer = selectedPomodoroTimer {
                if currentPomodoroState == .running {
                    backgroundManager?.addTimer(
                        id: "pomodoro_\(timer.id)",
                        endTime: Date().addingTimeInterval(timeRemaining)
                    )
                } else {
                    backgroundManager?.removeTimer(id: "pomodoro_\(timer.id)")
                }
            }
        } catch {
            print("Pomodoro durumu kaydedilemedi: \(error.localizedDescription)")
        }
    }
    
    private func loadPomodoroState() {
        if let data = UserDefaults.standard.data(forKey: "pomodoroState"),
           let state = try? JSONDecoder().decode(PomodoroState.self, from: data) {
            currentPomodoroState = state.timerState
            currentPhase = state.phase
            timeRemaining = state.timeRemaining
            completedSessions = state.completedSessions
            totalWorkTime = state.totalWorkTime
            totalCompletedSessions = state.totalCompletedSessions
            
            // Seçili zamanlayıcıyı bul
            if let timerId = state.selectedTimerId {
                selectedPomodoroTimer = pomodoroTimers.first { $0.id == timerId }
            }
            
            // Eğer zamanlayıcı çalışıyorsa, devam et
            if currentPomodoroState == .running {
                startTimer()
            }
        }
    }
    
    // MARK: - Timer Kontrol
    
    private func startTimer() {
        pomodoroTimer?.invalidate()
        
        pomodoroTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updatePomodoroTimer()
        }
        
        // Bildirim ayarla
        scheduleNotification()
    }
    
    // MARK: - Yardımcı Fonksiyonlar
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.calendar?.locale = Locale(identifier: "tr_TR")
        
        if timeInterval >= 86400 { // 1 gün veya daha fazla
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .full
        } else if timeInterval >= 3600 { // 1 saat veya daha fazla
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full
        } else {
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
        }
        
        let result = formatter.string(from: timeInterval) ?? "0 saniye"
        
        // İngilizce ifadeleri Türkçe'ye çevir
        return result
            .replacingOccurrences(of: "days", with: "gün")
            .replacingOccurrences(of: "day", with: "gün")
            .replacingOccurrences(of: "hours", with: "saat")
            .replacingOccurrences(of: "hour", with: "saat")
            .replacingOccurrences(of: "minutes", with: "dakika")
            .replacingOccurrences(of: "minute", with: "dakika")
            .replacingOccurrences(of: "seconds", with: "saniye")
            .replacingOccurrences(of: "second", with: "saniye")
    }
    
    // MARK: - Zamanlayıcı Özellikleri
    
    var progressValue: Double {
        guard let selectedTimer = selectedPomodoroTimer else { return 0 }
        
        let totalDuration: TimeInterval
        switch currentPhase {
        case .work:
            totalDuration = selectedTimer.workDuration
        case .break:
            totalDuration = selectedTimer.breakDuration
        case .longBreak:
            totalDuration = selectedTimer.longBreakDuration
        }
        
        if totalDuration <= 0 { return 0 }
        
        let progress = 1.0 - (timeRemaining / totalDuration)
        return max(0, min(1, progress))
    }
    
    var formattedTimeRemaining: String {
        return formatTime(timeRemaining)
    }
    
    var currentPhaseText: String {
        switch currentPhase {
        case .work:
            return "Çalışma Zamanı"
        case .break:
            return "Kısa Mola"
        case .longBreak:
            return "Uzun Mola"
        }
    }
    
    func scheduleNotification() {
        guard let _ = selectedPomodoroTimer, currentPomodoroState == .running else { return }
        
        let content = UNMutableNotificationContent()
        
        switch currentPhase {
        case .work:
            content.title = "Çalışma Süresi Bitti"
            content.body = "Tebrikler! Çalışma süreniz tamamlandı. Mola zamanı."
        case .break:
            content.title = "Kısa Mola Bitti"
            content.body = "Molanız bitti. Çalışmaya devam etme zamanı!"
        case .longBreak:
            content.title = "Uzun Mola Bitti"
            content.body = "Uzun molanız bitti. Çalışmaya devam etme zamanı!"
        }
        
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Bildirimler
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni alınamadı: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Arka Plan Güncellemeleri
    
    private func startBackgroundUpdates() {
        // Her dakika geri sayım zamanlayıcılarını güncelle
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
