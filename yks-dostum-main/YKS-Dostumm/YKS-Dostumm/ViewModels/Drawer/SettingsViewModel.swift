import Foundation
import Combine
import SwiftUI

class SettingsViewModel: BaseViewModelImpl {
    @Published var isDarkMode: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var dailyReminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var userName: String = "Kullanıcı"
    @Published var userEmail: String = ""
    @Published var appVersion: String = "1.0.0"
    @Published var profileImageData: Data? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadSettings()
    }
    
    func loadSettings() {
        isLoading = true
        
        // Simulate loading settings from UserDefaults or a database
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, you would load these from UserDefaults or a database
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
            
            if let savedName = UserDefaults.standard.string(forKey: "userName"), !savedName.isEmpty {
                self.userName = savedName
            }
            
            if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
                self.userEmail = savedEmail
            }
            
            if let savedTime = UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date {
                self.dailyReminderTime = savedTime
            }
            
            if let imageData = UserDefaults.standard.data(forKey: "profileImageData") {
                self.profileImageData = imageData
            }
            
            self.isLoading = false
        }
    }
    
    func saveSettings() {
        isLoading = true
        
        // Simulate saving settings to UserDefaults or a database
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, you would save these to UserDefaults or a database
            UserDefaults.standard.set(self.isDarkMode, forKey: "isDarkMode")
            UserDefaults.standard.set(self.notificationsEnabled, forKey: "notificationsEnabled")
            UserDefaults.standard.set(self.userName, forKey: "userName")
            UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
            UserDefaults.standard.set(self.dailyReminderTime, forKey: "dailyReminderTime")
            if let data = self.profileImageData {
                UserDefaults.standard.set(data, forKey: "profileImageData")
            } else {
                UserDefaults.standard.removeObject(forKey: "profileImageData")
            }
            
            // Apply dark mode setting
            self.applyDarkMode()
            
            self.isLoading = false
        }
    }
    
    private func applyDarkMode() {
        // In a real app, you would set the app's appearance here
        // For now, we'll just simulate it
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    func resetSettings() {
        isDarkMode = false
        notificationsEnabled = true
        dailyReminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        
        saveSettings()
    }
    
    func updateUserName(_ name: String) {
        userName = name
        saveSettings()
    }
    
    func updateUserEmail(_ email: String) {
        userEmail = email
        saveSettings()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        saveSettings()
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
        saveSettings()
    }
    
    func updateReminderTime(_ time: Date) {
        dailyReminderTime = time
        saveSettings()
    }
    
    func updateProfileImage(_ data: Data?) {
        profileImageData = data
        saveSettings()
    }
    
    func clearProfileImage() {
        profileImageData = nil
        saveSettings()
    }
}
