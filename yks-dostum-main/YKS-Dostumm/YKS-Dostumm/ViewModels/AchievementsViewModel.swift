import Foundation
import SwiftUI
import Combine

// Kategori özeti için model
struct AchievementCategoryInfo: Identifiable {
    var id = UUID()
    var name: String
    var iconName: String
    var completedCount: Int
    var totalCount: Int
}

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        isLoading = true
        
        // Eski verileri temizle ve her zaman güncel sample achievements'ı kullan
        userDefaults.removeObject(forKey: "userAchievements")
        self.achievements = Achievement.sampleAchievements
        saveAchievements()
        
        isLoading = false
    }
    
    func saveAchievements() {
        do {
            let achievementsData = try JSONEncoder().encode(achievements)
            userDefaults.set(achievementsData, forKey: "userAchievements")
        } catch {
            self.errorMessage = "Rozetler kaydedilemedi: \(error.localizedDescription)"
        }
    }
    
    func updateAchievement(id: UUID, newCount: Int) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].currentCount = newCount
            saveAchievements()
        }
    }
    
    func incrementAchievement(id: UUID) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].currentCount += 1
            saveAchievements()
        }
    }
    
    func getAchievementsByCategory(category: AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category.rawValue }
    }
    
    func getCompletedAchievementsCount() -> Int {
        return achievements.filter { $0.isCompleted }.count
    }
    
    func getTotalAchievementsCount() -> Int {
        return achievements.count
    }
    
    // Menüde gösterilecek kategorileri döndürür
    func getFeaturedCategories() -> [AchievementCategoryInfo] {
        let categories = AchievementCategory.allCases
        
        return categories.map { category in
            let categoryAchievements = getAchievementsByCategory(category: category)
            let completedCount = categoryAchievements.filter { $0.isCompleted }.count
            let totalCount = categoryAchievements.count
            
            return AchievementCategoryInfo(
                name: category.rawValue,
                iconName: getCategoryIcon(category),
                completedCount: completedCount,
                totalCount: totalCount
            )
        }
    }
    
    // Kategori için uygun icon
    public func getCategoryIcon(_ category: AchievementCategory) -> String {
        switch category {
        case .general:
            return "star.fill"
        case .challenges:
            return "trophy.fill"
        case .timeBased:
            return "timer"
        case .goals:
            return "target"
        case .study:
            return "book.fill"
        case .test:
            return "doc.text.fill"
        case .subject:
            return "list.bullet.clipboard"
        case .social:
            return "person.2.fill"
        }
    }
    
    // Check if there are any newly completed achievements
    func checkForNewlyCompletedAchievements() -> [Achievement] {
        let newlyCompleted = achievements.filter { 
            $0.isCompleted && $0.currentCount == $0.targetCount
        }
        return newlyCompleted
    }
}
