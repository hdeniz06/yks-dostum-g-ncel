import Foundation
import SwiftUI

// Color'ı Codable yapmak için extension
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let o = try container.decode(Double.self, forKey: .opacity)
        
        self.init(red: r, green: g, blue: b, opacity: o)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(o, forKey: .opacity)
    }
}

// Timer durumları
enum TimerState: Codable {
    case idle // Beklemede
    case running // Çalışıyor
    case paused // Duraklatıldı
    case stopped // Durduruldu
    case finished // Tamamlandı
}

// Pomodoro aşamaları
enum PomodoroPhase: Codable {
    case work // Çalışma
    case `break` // Kısa mola
    case longBreak // Uzun mola
}

// Pomodoro durumu için kullanılacak model
struct PomodoroState: Codable {

    let timerState: TimerState
    let phase: PomodoroPhase
    let timeRemaining: TimeInterval
    let completedSessions: Int
    let totalWorkTime: TimeInterval
    let totalCompletedSessions: Int
    let selectedTimerId: UUID?
}

// Pomodoro için kullanılacak model
struct PomodoroTimer: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var workDuration: TimeInterval // Çalışma süresi (saniye)
    var breakDuration: TimeInterval // Mola süresi (saniye)
    var longBreakDuration: TimeInterval // Uzun mola süresi (saniye)
    var sessionsBeforeLongBreak: Int // Uzun mola öncesi seans sayısı
    var totalSessions: Int // Toplam tamamlanan seans sayısı
    var totalWorkTime: TimeInterval // Toplam çalışma süresi (saniye)
    var isActive: Bool // Aktif mi?
    var createdAt: Date
    
    static func == (lhs: PomodoroTimer, rhs: PomodoroTimer) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(name: String, workDuration: TimeInterval = 25 * 60, breakDuration: TimeInterval = 5 * 60, 
         longBreakDuration: TimeInterval = 15 * 60, sessionsBeforeLongBreak: Int = 4) {
        self.name = name
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.longBreakDuration = longBreakDuration
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
        self.totalSessions = 0
        self.totalWorkTime = 0
        self.isActive = false
        self.createdAt = Date()
    }
}

// Geri sayım için kullanılacak model
struct CountdownTimer: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var targetDate: Date
    var createdAt: Date
    var color: Color // Renk bilgisi Color olarak saklanacak
    
    static func == (lhs: CountdownTimer, rhs: CountdownTimer) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(name: String, targetDate: Date, color: Color = .blue) {
        self.name = name
        self.targetDate = targetDate
        self.createdAt = Date()
        self.color = color
    }
    
    var timeRemaining: TimeInterval {
        return max(0, targetDate.timeIntervalSince(Date()))
    }
    
    var isExpired: Bool {
        return Date() >= targetDate
    }
}
