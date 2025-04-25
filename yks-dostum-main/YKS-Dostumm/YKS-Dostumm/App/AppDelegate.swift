import UIKit
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Bildirim izinlerini ayarla
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Bildirim izni verildi")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
        
        // Arka plan görevlerini ayarla (modern yaklaşım)
        registerBackgroundTasks()
        
        return true
    }
    
    // Modern BackgroundTasks çatısını kullanarak arka plan görevlerini kaydet
    private func registerBackgroundTasks() {
        // Zamanlayıcı güncellemesi için arka plan görevi
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yksdostum.timerUpdate", using: nil) { task in
            self.handleTimerUpdateTask(task: task as! BGAppRefreshTask)
        }
        
        // İlk görevi planla
        scheduleTimerUpdateTask()
    }
    
    // Zamanlayıcı güncelleme görevini planla
    private func scheduleTimerUpdateTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yksdostum.timerUpdate")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 dakika sonra
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Arka plan görevi planlama hatası: \(error.localizedDescription)")
        }
    }
    
    // Zamanlayıcı güncelleme görevini yönet
    private func handleTimerUpdateTask(task: BGAppRefreshTask) {
        // Bir sonraki görevi hemen planla
        scheduleTimerUpdateTask()
        
        // Güncellemeleri yapmak için görev tamamlanma işleyicisini ayarla
        task.expirationHandler = {
            // Süre dolduğunda işlemi sonlandır
            task.setTaskCompleted(success: false)
        }
        
        // Zamanlayıcıları güncelle
        NotificationCenter.default.post(name: NSNotification.Name("BackgroundTimerUpdate"), object: nil)
        
        // Görevi tamamla
        task.setTaskCompleted(success: true)
    }
    
    // Bildirimler için
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Uygulama açıkken de bildirimleri göster
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Bildirime tıklandığında yapılacak işlemler
        completionHandler()
    }
}
