import Foundation
import SwiftUI

struct KonuTakibi: Identifiable, Codable {
    var id: UUID
    var name: String
    var examType: ExamType
    var totalTopics: Int
    var completedTopics: Int
    var lastStudyDate: Date?
    var notes: String
    
    init(id: UUID = UUID(), name: String, examType: ExamType, totalTopics: Int = 1, completedTopics: Int = 0, lastStudyDate: Date? = nil, notes: String = "") {
        self.id = id
        self.name = name
        self.examType = examType
        self.totalTopics = max(1, totalTopics) // Ensure at least 1 topic
        self.completedTopics = min(completedTopics, totalTopics) // Ensure completed <= total
        self.lastStudyDate = lastStudyDate
        self.notes = notes
    }
    
    var isCompleted: Bool {
        return completedTopics >= totalTopics
    }
    
    var progress: Double {
        return totalTopics > 0 ? Double(completedTopics) / Double(totalTopics) : 0
    }
    
    var progressFormatted: String {
        return "\(completedTopics)/\(totalTopics)"
    }
    
    var lastStudyDateFormatted: String {
        guard let date = lastStudyDate else { return "Henüz çalışılmadı" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct KonuKategori: Identifiable, Codable {
    var id: UUID
    var name: String
    var subjects: [KonuTakibi]
    
    init(id: UUID = UUID(), name: String, subjects: [KonuTakibi] = []) {
        self.id = id
        self.name = name
        self.subjects = subjects
    }
}

// Static category data
enum YKSKategoriler {
    static let allCategories = [
        "Matematik",
        "Fizik",
        "Kimya",
        "Biyoloji",
        "Türkçe",
        "Tarih",
        "Coğrafya",
        "Felsefe"
    ]
    
    static func createDefaultCategories() -> [KonuKategori] {
        return allCategories.map { categoryName in
            KonuKategori(name: categoryName, subjects: [])
        }
    }
}
