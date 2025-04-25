import Foundation

struct StudyStats {
    var totalTasks: Int
    var completedTasks: Int
    var totalHours: Double
    var subjectHours: [String: Double]
    var subjectCompletion: [String: (completed: Int, total: Int)]
    var weeklyData: WeeklyData
    
    var completionPercentage: Double {
        return totalTasks > 0 ? (Double(completedTasks) / Double(totalTasks)) * 100 : 0
    }
    
    struct WeeklyData {
        var totalTasks: Int
        var completedTasks: Int
        var totalHours: Double
        
        var completionPercentage: Double {
            return totalTasks > 0 ? (Double(completedTasks) / Double(totalTasks)) * 100 : 0
        }
    }
}
