import Foundation
import SwiftUI
import UserNotifications

class TimerBackgroundManager: ObservableObject {
    private var activeTimers: [String: Date] = [:]
    private let userDefaults = UserDefaults.standard
    private var timer: Timer?
    
    init() {
        // Kaydedilmiş aktif zamanlayıcıları yükle
        loadTimers()
        
        // Bildirim izinlerini iste
        requestNotificationPermission()
        
        // Düzenli olarak zamanlayıcıları kontrol et
        setupTimerChecks()
        
        // Uygulama arka plana geçtiğinde ve öne geldiğinde bildirimleri ayarla
        setupAppStateObservers()
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadTimers() {
        if let timers = userDefaults.dictionary(forKey: "YKSDostum_ActiveTimers") as? [String: Date] {
            self.activeTimers = timers
        }
    }
    
    private func setupAppStateObservers() {
        // Uygulama arka plana geçtiğinde
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Uygulama öne geldiğinde
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        // Arka planda çalışacak zamanlayıcılar için bildirimler oluştur
        scheduleBackgroundNotifications()
    }
    
    @objc private func appWillEnterForeground() {
        // Zamanlanmış bildirimleri iptal et ve zamanlayıcıları kontrol et
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        checkTimers()
    }
    
    // Zamanlayıcı ekle
    func addTimer(id: String, endTime: Date) {
        activeTimers[id] = endTime
        saveActiveTimers()
        
        // Uygulama arka plandaysa bildirim oluştur
        if UIApplication.shared.applicationState == .background {
            scheduleBackgroundNotifications()
        }
    }
    
    // Zamanlayıcı kaldır
    func removeTimer(id: String) {
        activeTimers.removeValue(forKey: id)
        saveActiveTimers()
        
        // İlgili bildirimi iptal et
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // Aktif zamanlayıcıları kaydet
    private func saveActiveTimers() {
        userDefaults.set(activeTimers, forKey: "YKSDostum_ActiveTimers")
    }
    
    // Bildirim izinlerini iste
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni alınamadı: \(error.localizedDescription)")
            }
        }
    }
    
    // Arka planda bildirimler oluştur
    private func scheduleBackgroundNotifications() {
        // Önce tüm bekleyen bildirimleri temizle
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Her zamanlayıcı için bildirim oluştur
        for (id, endTime) in activeTimers {
            let timeInterval = endTime.timeIntervalSince(Date())
            
            // Sadece gelecekteki zamanlayıcılar için bildirim oluştur
            if timeInterval > 0 {
                createTimerNotification(id: id, timeInterval: timeInterval)
            }
        }
    }
    
    // Belirli bir zamanlayıcı için bildirim oluştur
    private func createTimerNotification(id: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        
        if id.starts(with: "pomodoro") {
            content.title = "Pomodoro Tamamlandı"
            content.body = "Çalışma seansınız sona erdi. Şimdi mola zamanı!"
        } else {
            content.title = "Zamanlayıcı Tamamlandı"
            content.body = "Ayarladığınız zamanlayıcı sona erdi."
        }
        
        content.sound = .default
        
        // Zamanlayıcı tetikleyici
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Bildirim isteği
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // Bildirimi ekle
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim oluşturulamadı: \(error.localizedDescription)")
            }
        }
    }
    
    // Zamanlayıcı kontrolleri için düzenli kontrol
    private func setupTimerChecks() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.checkTimers()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // Zamanlayıcıları kontrol et
    private func checkTimers() {
        let now = Date()
        var shouldUpdate = false
        
        for (id, endTime) in activeTimers {
            if now >= endTime {
                // Zamanlayıcı tamamlandı, bildirim gönder (uygulama öndeyse)
                if UIApplication.shared.applicationState == .active {
                    sendTimerCompletionNotification(id: id)
                }
                
                // Zamanlayıcıyı kaldır
                activeTimers.removeValue(forKey: id)
                shouldUpdate = true
            }
        }
        
        if shouldUpdate {
            saveActiveTimers()
        }
    }
    
    // Zamanlayıcı tamamlandığında bildirim gönder (uygulama öndeyken)
    private func sendTimerCompletionNotification(id: String) {
        let content = UNMutableNotificationContent()
        
        if id.starts(with: "pomodoro") {
            content.title = "Pomodoro Tamamlandı"
            content.body = "Çalışma seansınız sona erdi. Şimdi mola zamanı!"
        } else {
            content.title = "Zamanlayıcı Tamamlandı"
            content.body = "Ayarladığınız zamanlayıcı sona erdi."
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
