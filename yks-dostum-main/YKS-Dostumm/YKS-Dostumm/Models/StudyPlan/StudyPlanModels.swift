import Foundation

// MARK: - Study Plan Models

// Main model representing a complete study plan
struct StudyPlan: Codable, Identifiable {
    var id: UUID = UUID()
    var days: [StudyDay]
    var lastUpdated: Date = Date()
    
    // Calculate total study hours for the entire plan
    var totalStudyHours: Double {
        days.reduce(0) { $0 + $1.totalHours }
    }
    
    // Calculate total completed tasks
    var totalCompletedTasks: Int {
        days.reduce(0) { $0 + $1.completedTasksCount }
    }
    
    // Calculate total tasks
    var totalTasks: Int {
        days.reduce(0) { $0 + $1.tasks.count }
    }
    
    // Calculate completion percentage
    var completionPercentage: Double {
        if totalTasks == 0 { return 0 }
        return Double(totalCompletedTasks) / Double(totalTasks) * 100
    }
}

// Model representing a single day in the study plan
struct StudyDay: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var date: Date
    var tasks: [StudyTask]
    
    // Calculate total study hours for this day
    var totalHours: Double {
        tasks.reduce(0) { $0 + $1.duration }
    }
    
    // Count of completed tasks
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    // Calculate completion percentage for this day
    var completionPercentage: Double {
        if tasks.isEmpty { return 0 }
        return Double(completedTasksCount) / Double(tasks.count) * 100
    }
    
    static func == (lhs: StudyDay, rhs: StudyDay) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Model representing a single study task
struct StudyTask: Codable, Identifiable, Hashable {
    var id: UUID
    var subject: String
    var description: String
    var startTime: Date
    var duration: Double // in hours
    var isCompleted: Bool
    var priority: TaskPriority
    var notes: String?
    var category: StudyCategory
    
    // Calculate end time based on start time and duration
    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: Int(duration * 60), to: startTime)!
    }
    
    // Default initializer with common values
    init(
        id: UUID = UUID(),
        subject: String,
        description: String,
        startTime: Date,
        duration: Double,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        notes: String? = nil,
        category: StudyCategory = .general
    ) {
        self.id = id
        self.subject = subject
        self.description = description
        self.startTime = startTime
        self.duration = duration
        self.isCompleted = isCompleted
        self.priority = priority
        self.notes = notes
        self.category = category
    }
    
    static func == (lhs: StudyTask, rhs: StudyTask) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Task priority levels
enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low = "Düşük"
    case medium = "Orta"
    case high = "Yüksek"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

// Study categories for better organization
enum StudyCategory: String, Codable, CaseIterable, Identifiable {
    case general = "Genel"
    case subjectReview = "Konu Tekrarı"
    case problemSolving = "Soru Çözümü"
    case mockExam = "Deneme Sınavı"
    case watchVideo = "Video Eğitim"
    case notes = "Not Alma"
    case revision = "Tekrar"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .general: return "book.fill"
        case .subjectReview: return "text.book.closed.fill"
        case .problemSolving: return "questionmark.circle.fill"
        case .mockExam: return "doc.text.fill"
        case .watchVideo: return "play.rectangle.fill"
        case .notes: return "note.text"
        case .revision: return "arrow.clockwise"
        }
    }
}
