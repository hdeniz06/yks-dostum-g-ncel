import Foundation
import SwiftUI

// Ana sayfada görüntülenecek günlük özet
struct DailyStudySummary: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var totalStudyHours: Double
    var completedTasks: Int
    var totalTasks: Int
    var mostStudiedSubject: String
    
    var completionRate: Double {
        return totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
    }
    
    var formattedStudyHours: String {
        let hours = Int(totalStudyHours)
        let minutes = Int((totalStudyHours - Double(hours)) * 60)
        return "\(hours) saat \(minutes) dakika"
    }
}

// Önerilen çalışma konuları
struct StudySuggestion: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subject: String
    var reasonForSuggestion: SuggestionReason
    var examType: ExamType
    var difficulty: Int // 1-5 arası zorluk derecesi
    var estimatedDuration: Int // Dakika cinsinden tahmini süre
    var lastStudied: Date?
    
    enum SuggestionReason: String, Codable, CaseIterable {
        case lowPerformance = "Düşük Performans"
        case notStudiedRecently = "Uzun Süredir Çalışılmadı"
        case upcomingExam = "Yaklaşan Sınav"
        case frequentMistakes = "Sık Yapılan Hatalar"
        case recommendedByAI = "AI Tavsiyesi"
        case personalStrength = "Güçlü Olduğun Konu"
        
        var icon: String {
            switch self {
            case .lowPerformance: return "chart.line.downtrend.xyaxis"
            case .notStudiedRecently: return "clock.arrow.circlepath"
            case .upcomingExam: return "calendar.badge.exclamationmark"
            case .frequentMistakes: return "exclamationmark.triangle"
            case .recommendedByAI: return "brain.head.profile"
            case .personalStrength: return "chart.bar.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .lowPerformance: return .red
            case .notStudiedRecently: return .blue
            case .upcomingExam: return .orange
            case .frequentMistakes: return .yellow
            case .recommendedByAI: return .purple
            case .personalStrength: return .green
            }
        }
    }
}

// Yaklaşan deneme sınavları
struct UpcomingExam: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var location: String?
    var examProvider: String
    var subjects: [String]
    var isPractice: Bool // Deneme mi gerçek sınav mı?
    var isRegistered: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExamDay = calendar.startOfDay(for: date)
        if let days = calendar.dateComponents([.day], from: startOfToday, to: startOfExamDay).day {
            return max(days, 0)
        }
        return 0
    }
}

// Haftalık çalışma verileri
struct WeeklyStudyData: Identifiable, Codable {
    var id = UUID()
    var weekStarting: Date
    var dailyHours: [Double] // Haftanın 7 günü için çalışma saatleri
    var subjectDistribution: [String: Double] // Konu bazında çalışma oranları
    
    var totalHours: Double {
        return dailyHours.reduce(0, +)
    }
    
    var averageHoursPerDay: Double {
        return totalHours / Double(dailyHours.count)
    }
}

// Başarı kartı
struct AchievementCard: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var dateEarned: Date
    var type: AchievementType
    var icon: String
    
    enum AchievementType: String, Codable, CaseIterable {
        case streak = "Çalışma Serisi"
        case milestone = "Kilometre Taşı"
        case improvement = "İlerleme"
        case excellence = "Mükemmellik"
        case consistency = "Tutarlılık"
        
        var color: Color {
            switch self {
            case .streak: return .orange
            case .milestone: return .blue
            case .improvement: return .green
            case .excellence: return .purple
            case .consistency: return .indigo
            }
        }
    }
}

// Bugünün hedefleri (yapılacak görevler)
struct DailyGoal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subject: String?
    var isCompleted: Bool
    var priority: Priority
    var deadline: Date?
    var createdAt: Date
    
    enum Priority: Int, Codable, CaseIterable, Identifiable {
        case low = 1
        case medium = 2
        case high = 3
        
        var id: Int { self.rawValue }
        
        var title: String {
            switch self {
            case .low: return "Düşük"
            case .medium: return "Orta"
            case .high: return "Yüksek"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .blue
            case .medium: return .orange
            case .high: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "arrow.down.circle.fill"
            case .medium: return "equal.circle.fill"
            case .high: return "arrow.up.circle.fill"
            }
        }
    }
}

// Çalışma arkadaşı aktivitesi
struct StudyBuddyActivity: Identifiable, Codable {
    var id = UUID()
    var friendName: String
    var avatarURL: URL?
    var activityType: ActivityType
    var subject: String?
    var timestamp: Date
    
    enum ActivityType: String, Codable, CaseIterable {
        case completedTask = "Görevi Tamamladı"
        case reachedMilestone = "Hedefe Ulaştı"
        case studiedHours = "Çalıştı"
        case joinedChallenge = "Mücadeleye Katıldı"
        case sharedNote = "Not Paylaştı"
        
        var icon: String {
            switch self {
            case .completedTask: return "checkmark.circle.fill"
            case .reachedMilestone: return "flag.fill"
            case .studiedHours: return "clock.fill"
            case .joinedChallenge: return "flame.fill"
            case .sharedNote: return "note.text"
            }
        }
    }
    
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
