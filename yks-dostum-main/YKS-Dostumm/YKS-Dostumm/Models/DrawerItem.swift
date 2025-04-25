import Foundation
import SwiftUI

enum DrawerItemType: String, Identifiable, CaseIterable {
    case dashboard = "Ana Sayfa"
    case studyPlan = "Çalışma Planı"
    case subjectTracking = "Konu Takibi"
    case testResults = "Deneme Sonuçları"
    case aiAssistant = "YKS Asistanı"

    case timers = "Sayaç"
    case settings = "Ayarlar"
    case library = "Yakınımdaki Kütüphaneler"
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .studyPlan: return "calendar"
        case .subjectTracking: return "list.bullet.clipboard"
        case .testResults: return "chart.bar.fill"
        case .aiAssistant: return "bubble.left.and.bubble.right.fill"

        case .library : return "books.vertical.fill"
        case .timers: return "timer"
        case .settings: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard: return .blue
        case .studyPlan: return .green
        case .subjectTracking: return .orange
        case .testResults: return .purple
        case .aiAssistant: return .pink

        case .library : return .orange
        case .timers: return .red
        case .settings: return .gray
        }
    }
}
