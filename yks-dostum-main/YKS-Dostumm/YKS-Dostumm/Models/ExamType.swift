import Foundation
import SwiftUI

enum ExamType: String, Codable, CaseIterable, Identifiable {
    case tyt = "TYT"
    case ayt = "AYT"
    case ydt = "YDT"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .tyt: return .blue
        case .ayt: return .orange
        case .ydt: return .green
        }
    }
}
