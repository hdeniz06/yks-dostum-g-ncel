import Foundation
import Combine

// MARK: - Models
enum TestFilter: String, CaseIterable {
    case all = "Tümü"
    case tyt = "TYT"
    case ayt = "AYT"
    case ydt = "YDT"
    
    var id: String { self.rawValue }
}

enum TimeRange: String, CaseIterable {
    case lastWeek = "Son Hafta"
    case lastMonth = "Son Ay"
    case lastThreeMonths = "Son 3 Ay"
    case allTime = "Tüm Zamanlar"
    
    var id: String { self.rawValue }
}

import SwiftUI

enum SubjectTrend {
    case improving
    case declining
    case stable
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right.circle.fill"
        case .declining: return "arrow.down.right.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .blue
        }
    }
}

struct ProgressData {
    var averageNetScore: Double = 0
    var averagePercentage: Double = 0
    var bestSubject: String = ""
    var bestSubjectScore: Double = 0
    var worstSubject: String = ""
    var worstSubjectScore: Double = 0
    var improvement: Double = 0
    var testCount: Int = 0
}

struct TestResult: Identifiable {
    var id: UUID
    var name: String
    var examType: ExamType
    var date: Date
    var totalQuestions: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var emptyAnswers: Int
    var netScore: Double
    var subjectScores: [SubjectScore]
    
    var scorePercentage: Double {
        return (netScore / Double(totalQuestions)) * 100
    }
}

struct SubjectScore: Identifiable {
    var id = UUID()
    var subject: String
    var score: Double
}

// MARK: - Service
class TestResultService {
    func filterTestResults(by filter: TestFilter, testResults: [TestResult]) -> [TestResult] {
        switch filter {
        case .all:
            return testResults
        case .tyt:
            return testResults.filter { $0.examType == .tyt }
        case .ayt:
            return testResults.filter { $0.examType == .ayt }
        case .ydt:
            return testResults.filter { $0.examType == .ydt }
        }
    }
    
    func calculateSubjectAverages(for testResults: [TestResult]) -> [SubjectScore] {
        var subjectScores: [String: [Double]] = [:]
        
        for result in testResults {
            for score in result.subjectScores {
                if subjectScores[score.subject] == nil {
                    subjectScores[score.subject] = []
                }
                subjectScores[score.subject]?.append(score.score)
            }
        }
        
        // Convert to array of SubjectScore with average values
        return subjectScores.map { subject, scores in
            let average = scores.reduce(0, +) / Double(scores.count)
            return SubjectScore(subject: subject, score: average)
        }.sorted { $0.score > $1.score } // Sort by score descending to show strengths first
    }
    
    func calculateProgressData(for testResults: [TestResult], timeRange: TimeRange) -> ProgressData {
        guard !testResults.isEmpty else {
            return ProgressData()
        }
        
        // Filter tests by time range
        let filteredByTime = filterByTimeRange(testResults: testResults, timeRange: timeRange)
        guard !filteredByTime.isEmpty else {
            return ProgressData()
        }
        
        // Calculate average score
        let totalNetScore = filteredByTime.reduce(0) { $0 + $1.netScore }
        let averageNetScore = totalNetScore / Double(filteredByTime.count)
        
        // Calculate average percentage
        let totalPercentage = filteredByTime.reduce(0) { $0 + $1.scorePercentage }
        let averagePercentage = totalPercentage / Double(filteredByTime.count)
        
        // Find best and worst subjects
        var subjectAverages: [String: Double] = [:]
        for result in filteredByTime {
            for score in result.subjectScores {
                if subjectAverages[score.subject] == nil {
                    subjectAverages[score.subject] = score.score
                } else {
                    subjectAverages[score.subject] = (subjectAverages[score.subject]! + score.score) / 2
                }
            }
        }
        
        let bestSubject = subjectAverages.max { $0.value < $1.value }
        let worstSubject = subjectAverages.min { $0.value < $1.value }
        
        // Calculate improvement
        var improvement = 0.0
        if filteredByTime.count >= 2 {
            // Sort by date (oldest first)
            let sortedResults = filteredByTime.sorted { $0.date < $1.date }
            let firstTest = sortedResults.first!
            let lastTest = sortedResults.last!
            improvement = lastTest.scorePercentage - firstTest.scorePercentage
        }
        
        // Update progress data
        return ProgressData(
            averageNetScore: averageNetScore,
            averagePercentage: averagePercentage,
            bestSubject: bestSubject?.key ?? "",
            bestSubjectScore: bestSubject?.value ?? 0,
            worstSubject: worstSubject?.key ?? "",
            worstSubjectScore: worstSubject?.value ?? 0,
            improvement: improvement,
            testCount: filteredByTime.count
        )
    }
    
    func filterByTimeRange(testResults: [TestResult], timeRange: TimeRange) -> [TestResult] {
        let calendar = Calendar.current
        let today = Date()
        
        switch timeRange {
        case .lastWeek:
            guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return [] }
            return testResults.filter { $0.date >= oneWeekAgo }
        case .lastMonth:
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today) else { return [] }
            return testResults.filter { $0.date >= oneMonthAgo }
        case .lastThreeMonths:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) else { return [] }
            return testResults.filter { $0.date >= threeMonthsAgo }
        case .allTime:
            return testResults
        }
    }
    
    func getSubjectTrend(for subject: String, in testResults: [TestResult]) -> SubjectTrend {
        let relevantTests = testResults.sorted { $0.date < $1.date } // Sort by date, oldest first
        
        var scores: [Double] = []
        for test in relevantTests {
            if let subjectScore = test.subjectScores.first(where: { $0.subject == subject }) {
                scores.append(subjectScore.score)
            }
        }
        
        guard scores.count >= 2 else { return .stable }
        
        let firstScore = scores.first!
        let lastScore = scores.last!
        let difference = lastScore - firstScore
        
        if difference >= 2.0 {
            return .improving
        } else if difference <= -2.0 {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - ViewModel
class TestResultsViewModel: BaseViewModelImpl {
    // MARK: - Published Properties
    @Published var testResults: [TestResult] = []
    @Published var selectedFilter: TestFilter = .all
    @Published var chartData: [SubjectScore] = []
    @Published var progressData: ProgressData = ProgressData()
    @Published var selectedTimeRange: TimeRange = .lastMonth
    @Published var showingInsights: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let testResultService = TestResultService()
    
    // MARK: - Computed Properties
    var filteredTestResults: [TestResult] {
        return testResultService.filterTestResults(by: selectedFilter, testResults: testResults)
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        loadTestResults()
    }
    
    // MARK: - Public Methods
    func loadTestResults() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample test results
            self.testResults = self.generateSampleTestResults()
            self.updateChartData()
            self.calculateProgressData()
            self.isLoading = false
        }
    }
    
    func updateChartData() {
        chartData = testResultService.calculateSubjectAverages(for: filteredTestResults)
    }
    
    func calculateProgressData() {
        progressData = testResultService.calculateProgressData(for: filteredTestResults, timeRange: selectedTimeRange)
    }
    
    func addTestResult(_ result: TestResult) {
        testResults.append(result)
        testResults.sort { $0.date > $1.date } // Sort by date, newest first
        updateChartData()
        calculateProgressData()
    }
    
    /// Returns the performance trend for a specific subject based on current filtered results
    func getSubjectTrend(for subject: String) -> SubjectTrend {
        return testResultService.getSubjectTrend(for: subject, in: filteredTestResults)
    }
    
    // Helper function to generate sample data
    private func generateSampleTestResults() -> [TestResult] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        // TYT Test Results
        let tytTest1 = TestResult(
            id: UUID(),
            name: "TYT Deneme 1",
            examType: .tyt,
            date: dateFormatter.date(from: "10/04/2025")!,
            totalQuestions: 120,
            correctAnswers: 85,
            wrongAnswers: 25,
            emptyAnswers: 10,
            netScore: 78.75,
            subjectScores: [
                SubjectScore(subject: "Türkçe", score: 32.5),
                SubjectScore(subject: "Matematik", score: 25.0),
                SubjectScore(subject: "Fizik", score: 7.5),
                SubjectScore(subject: "Kimya", score: 6.25),
                SubjectScore(subject: "Biyoloji", score: 5.0),
                SubjectScore(subject: "Tarih", score: 2.5)
            ]
        )
        
        let tytTest2 = TestResult(
            id: UUID(),
            name: "TYT Deneme 2",
            examType: .tyt,
            date: dateFormatter.date(from: "25/03/2025")!,
            totalQuestions: 120,
            correctAnswers: 80,
            wrongAnswers: 30,
            emptyAnswers: 10,
            netScore: 72.5,
            subjectScores: [
                SubjectScore(subject: "Türkçe", score: 30.0),
                SubjectScore(subject: "Matematik", score: 22.5),
                SubjectScore(subject: "Fizik", score: 7.5),
                SubjectScore(subject: "Kimya", score: 5.0),
                SubjectScore(subject: "Biyoloji", score: 5.0),
                SubjectScore(subject: "Tarih", score: 2.5)
            ]
        )
        
        // AYT Test Results
        let aytTest1 = TestResult(
            id: UUID(),
            name: "AYT Deneme 1",
            examType: .ayt,
            date: dateFormatter.date(from: "05/04/2025")!,
            totalQuestions: 160,
            correctAnswers: 95,
            wrongAnswers: 45,
            emptyAnswers: 20,
            netScore: 83.75,
            subjectScores: [
                SubjectScore(subject: "Matematik", score: 30.0),
                SubjectScore(subject: "Fizik", score: 12.5),
                SubjectScore(subject: "Kimya", score: 10.0),
                SubjectScore(subject: "Biyoloji", score: 7.5),
                SubjectScore(subject: "Edebiyat", score: 15.0),
                SubjectScore(subject: "Tarih", score: 5.0),
                SubjectScore(subject: "Coğrafya", score: 3.75)
            ]
        )
        
        let aytTest2 = TestResult(
            id: UUID(),
            name: "AYT Deneme 2",
            examType: .ayt,
            date: dateFormatter.date(from: "20/03/2025")!,
            totalQuestions: 160,
            correctAnswers: 90,
            wrongAnswers: 50,
            emptyAnswers: 20,
            netScore: 77.5,
            subjectScores: [
                SubjectScore(subject: "Matematik", score: 27.5),
                SubjectScore(subject: "Fizik", score: 10.0),
                SubjectScore(subject: "Kimya", score: 10.0),
                SubjectScore(subject: "Biyoloji", score: 7.5),
                SubjectScore(subject: "Edebiyat", score: 12.5),
                SubjectScore(subject: "Tarih", score: 5.0),
                SubjectScore(subject: "Coğrafya", score: 5.0)
            ]
        )
        
        // Add more tests to show progress
        let tytTest3 = TestResult(
            id: UUID(),
            name: "TYT Deneme 3",
            examType: .tyt,
            date: dateFormatter.date(from: "15/04/2025")!,
            totalQuestions: 120,
            correctAnswers: 90,
            wrongAnswers: 20,
            emptyAnswers: 10,
            netScore: 85.0,
            subjectScores: [
                SubjectScore(subject: "Türkçe", score: 35.0),
                SubjectScore(subject: "Matematik", score: 27.5),
                SubjectScore(subject: "Fizik", score: 8.75),
                SubjectScore(subject: "Kimya", score: 6.25),
                SubjectScore(subject: "Biyoloji", score: 5.0),
                SubjectScore(subject: "Tarih", score: 2.5)
            ]
        )
        
        return [tytTest1, tytTest2, aytTest1, aytTest2, tytTest3].sorted { $0.date > $1.date }
    }
}
