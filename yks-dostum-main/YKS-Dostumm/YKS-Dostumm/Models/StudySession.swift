import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    var topic: String
    var targetDuration: TimeInterval // in seconds
    var completedDuration: TimeInterval // in seconds
    var date: Date
    
    init(topic: String, targetDuration: TimeInterval, completedDuration: TimeInterval = 0, date: Date = Date()) {
        self.id = UUID()
        self.topic = topic
        self.targetDuration = targetDuration
        self.completedDuration = completedDuration
        self.date = date
    }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var achievedDate: Date
    
    init(name: String, description: String, achievedDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.achievedDate = achievedDate
    }
}
