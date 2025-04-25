import Foundation
import Combine
import SwiftUI

class StudyPlanViewModel: BaseViewModelImpl {
    // MARK: - Published Properties
    @Published var studyDays: [StudyDay] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedWeek: [Date] = []
    @Published var studyStats = StudyStats(totalTasks: 0, completedTasks: 0, totalHours: 0.0, subjectHours: [:], subjectCompletion: [:], weeklyData: StudyStats.WeeklyData(totalTasks: 0, completedTasks: 0, totalHours: 0.0))
    @Published var filteredSubject: String? = nil
    @Published var displayMode: DisplayMode = .calendar
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let studyPlanKey = "userStudyPlan"
    
    // MARK: - Enums
    enum DisplayMode: String, CaseIterable {
        case calendar = "Takvim"
        case list = "Liste"
        case statistics = "İstatistikler"
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        generateWeekDates()
        loadStudyPlan()
        setupBindings()
    }
    
    // MARK: - Subjects List
    lazy var availableSubjects: [String] = {
        return ["Matematik", 
                "Fizik", "Kimya", "Biyoloji", 
                "Türkçe", "Edebiyat", "Tarih", "Coğrafya", 
                "Felsefe", "Din Kültürü", "İngilizce"]
    }()
    
    // MARK: - Setup
    private func setupBindings() {
        // Update statistics whenever study days change
        $studyDays
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] days in
                self?.updateStatistics(days: days)
                self?.saveStudyPlan()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Date Navigation Methods
    func generateWeekDates() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        
        selectedWeek = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startDate)!
        }
    }
    
    func moveToNextWeek() {
        let calendar = Calendar.current
        if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
            selectedDate = nextWeek
            generateWeekDates()
        }
    }
    
    func moveToPreviousWeek() {
        let calendar = Calendar.current
        if let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
            selectedDate = previousWeek
            generateWeekDates()
        }
    }
    
    func moveToDate(_ date: Date) {
        selectedDate = date
        generateWeekDates()
    }
    
    func moveToToday() {
        selectedDate = Date()
        generateWeekDates()
    }
    
    // MARK: - Data Loading/Saving Methods
    func loadStudyPlan() {
        isLoading = true
        
        // Try to load saved data
        if let savedData = userDefaults.data(forKey: studyPlanKey),
           let decodedDays = try? JSONDecoder().decode([StudyDay].self, from: savedData) {
            self.studyDays = decodedDays
            updateStatistics(days: decodedDays)
            isLoading = false
        } else {
            // If no saved data, generate sample data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.studyDays = self.generateSampleStudyPlan()
                self.updateStatistics(days: self.studyDays)
                self.isLoading = false
            }
        }
    }
    
    private func saveStudyPlan() {
        if let encodedData = try? JSONEncoder().encode(studyDays) {
            userDefaults.set(encodedData, forKey: studyPlanKey)
        }
    }
    
    // MARK: - Task Management Methods
    func addStudyTask(date: Date, task: StudyTask) {
        if let index = studyDays.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            studyDays[index].tasks.append(task)
            // Sort tasks by start time
            studyDays[index].tasks.sort { $0.startTime < $1.startTime }
        } else {
            let newDay = StudyDay(date: date, tasks: [task])
            studyDays.append(newDay)
            // Sort study days by date
            studyDays.sort { $0.date < $1.date }
        }
    }
    
    func updateTask(dayIndex: Int, taskIndex: Int, updatedTask: StudyTask) {
        guard dayIndex < studyDays.count, taskIndex < studyDays[dayIndex].tasks.count else { return }
        
        studyDays[dayIndex].tasks[taskIndex] = updatedTask
        // Resort tasks in case start time changed
        studyDays[dayIndex].tasks.sort { $0.startTime < $1.startTime }
    }
    
    func deleteTask(dayIndex: Int, taskIndex: Int) {
        guard dayIndex < studyDays.count, taskIndex < studyDays[dayIndex].tasks.count else { return }
        
        studyDays[dayIndex].tasks.remove(at: taskIndex)
        
        // If day has no more tasks, remove the day
        if studyDays[dayIndex].tasks.isEmpty {
            studyDays.remove(at: dayIndex)
        }
    }
    
    func toggleTaskCompletion(dayIndex: Int, taskIndex: Int) {
        guard dayIndex < studyDays.count, taskIndex < studyDays[dayIndex].tasks.count else { return }
        
        studyDays[dayIndex].tasks[taskIndex].isCompleted.toggle()
    }
    
    // MARK: - Statistics and Filtering
    private func updateStatistics(days: [StudyDay]) {
        let totalTasks = days.reduce(0) { $0 + $1.tasks.count }
        let completedTasks = days.reduce(0) { $0 + $1.completedTasksCount }
        let totalHours = days.reduce(0.0) { $0 + $1.totalHours }
        
        var subjectHours: [String: Double] = [:]
        var subjectCompletion: [String: (completed: Int, total: Int)] = [:]
        
        for day in days {
            for task in day.tasks {
                // Accumulate hours by subject
                subjectHours[task.subject, default: 0] += task.duration
                
                // Track completion by subject
                var current = subjectCompletion[task.subject, default: (0, 0)]
                current.total += 1
                if task.isCompleted {
                    current.completed += 1
                }
                subjectCompletion[task.subject] = current
            }
        }
        
        // Calculate weekly progress
        let thisWeekDays = days.filter { day in
            selectedWeek.contains { Calendar.current.isDate($0, inSameDayAs: day.date) }
        }
        
        let weeklyStats = StudyStats.WeeklyData(
            totalTasks: thisWeekDays.reduce(0) { $0 + $1.tasks.count },
            completedTasks: thisWeekDays.reduce(0) { $0 + $1.completedTasksCount },
            totalHours: thisWeekDays.reduce(0.0) { $0 + $1.totalHours }
        )
        
        // Update the published stats
        studyStats = StudyStats(
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            totalHours: totalHours,
            subjectHours: subjectHours,
            subjectCompletion: subjectCompletion,
            weeklyData: StudyStats.WeeklyData(
                totalTasks: weeklyStats.totalTasks,
                completedTasks: weeklyStats.completedTasks,
                totalHours: weeklyStats.totalHours
            )
        )
    }
    
    func tasksForSelectedWeek() -> [StudyTask] {
        var allTasks: [StudyTask] = []
        
        // Find tasks for each day in the selected week
        for weekDay in selectedWeek {
            if let dayIndex = studyDays.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: weekDay) }) {
                allTasks.append(contentsOf: studyDays[dayIndex].tasks)
            }
        }
        
        // Apply subject filter if needed
        if let subject = filteredSubject {
            allTasks = allTasks.filter { $0.subject == subject }
        }
        
        return allTasks.sorted { $0.startTime < $1.startTime }
    }
    
    func tasksForDay(_ date: Date) -> [StudyTask] {
        guard let dayIndex = studyDays.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return []
        }
        
        var tasks = studyDays[dayIndex].tasks
        
        // Apply subject filter if needed
        if let subject = filteredSubject {
            tasks = tasks.filter { $0.subject == subject }
        }
        
        return tasks.sorted { $0.startTime < $1.startTime }
    }
    
    // MARK: - Helper Methods
    func getDayIndex(for date: Date) -> Int? {
        return studyDays.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
    
    func getWeekDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    func getFullFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Sample Data Generation
    private func generateSampleStudyPlan() -> [StudyDay] {
        let taskTypes = [StudyCategory.subjectReview, .problemSolving, .mockExam, .watchVideo, .notes]
        
        // Generate tasks for the last 2 weeks and the next 2 weeks
        let calendar = Calendar.current
        let today = Date()
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today)!
        let twoWeeksLater = calendar.date(byAdding: .day, value: 14, to: today)!
        
        var allDates: [Date] = []
        var currentDate = twoWeeksAgo
        
        while currentDate <= twoWeeksLater {
            allDates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return allDates.map { date in
            // More tasks for weekdays, fewer for weekends
            let isWeekend = calendar.isDateInWeekend(date)
            let tasksCount = isWeekend ? Int.random(in: 1...3) : Int.random(in: 2...5)
            
            let tasks = (0..<tasksCount).map { _ in
                let subject = availableSubjects.randomElement()!
                let category = taskTypes.randomElement()!
                let duration = Double.random(in: 1...3)
                let isCompleted = Calendar.current.isDateInToday(date) ? false : date < today ? Bool.random() : false
                let priority: TaskPriority = [.low, .medium, .high].randomElement()!
                
                return StudyTask(
                    id: UUID(),
                    subject: subject,
                    description: "\(subject) \(category.rawValue)",
                    startTime: calendar.date(bySettingHour: Int.random(in: 9...18), minute: [0, 30].randomElement()!, second: 0, of: date)!,
                    duration: duration,
                    isCompleted: isCompleted,
                    priority: priority,
                    category: category
                )
            }.sorted { $0.startTime < $1.startTime }
            
            return StudyDay(date: date, tasks: tasks)
        }
    }
}


