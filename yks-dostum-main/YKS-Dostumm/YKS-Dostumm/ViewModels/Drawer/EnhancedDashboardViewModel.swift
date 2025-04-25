import Foundation
import Combine
import SwiftUI

class EnhancedDashboardViewModel: ObservableObject {
    // Motivasyon sözleri
    @Published var motivationalQuote: String = ""
    
    // Günlük özet
    @Published var dailySummary: DailyStudySummary?
    
    // Önerilen çalışma konuları
    @Published var suggestedTopics: [StudySuggestion] = []
    
    // Yaklaşan sınavlar
    @Published var upcomingExams: [UpcomingExam] = []
    
    // Haftalık çalışma verileri
    @Published var weeklyData: WeeklyStudyData?
    
    // Başarı kartları
    @Published var recentAchievements: [AchievementCard] = []
    
    // Bugünün hedefleri
    @Published var todaysGoals: [DailyGoal] = []
    
    // Çalışma arkadaşları aktiviteleri
    @Published var buddyActivities: [StudyBuddyActivity] = []
    
    // Görünüm seçenekleri
    @Published var showDetailedStats: Bool = false
    @Published var selectedGoalFilter: GoalFilter = .all
    
    // Yükleniyor durumu
    @Published var isLoading: Bool = false
    
    // Timer'ı saklayacak değişken
    private var quoteTimer: Timer?
    
    // Motivasyon sözleri listesi
    private let motivationalQuotes = [
        "Başarı, her gün küçük çabalarla elde edilir.",
        "Bugün yaptığın çalışma, yarının başarısının temelidir.",
        "Zorluklar, başarıya giden yoldaki basamaklardır.",
        "Vazgeçmek yok, her gün bir adım daha ileri.",
        "Başarı tesadüf değil, disiplinli çalışmanın sonucudur.",
        "Hedefine ulaşmak için her gün kendini biraz daha zorla.",
        "Yolun sonunda seni bekleyen başarı, bugünkü çabanla şekilleniyor.",
        "Hayallerine ulaşmak için çalışmaktan asla vazgeçme.",
        "Başarılı insanlar, başarısız olduklarında pes etmezler.",
        "Bugün yapamadığını düşündüğün şey, yarın başaracağın şeydir.",
        "Çalışmak için motivasyon bekleme, çalışmak motivasyonu getirir.",
        "Bir günde bir mucize bekleme, her gün bir adım at.",
        "YKS bir maraton, her gün temponu koru.",
        "Başarı, küçük çabaların toplamıdır.",
        "Kendine inan, yapabilirsin!",
        "Zorluklar, seni daha güçlü yapar.",
        "Bugün yaptığın fedakarlıklar, yarın özgürlüğün olacak.",
        "Çalışmak şimdi zor gelebilir, ama pişmanlık daha zordur.",
        "Başarı, düştükten sonra bir kez daha kalkmaktır.",
        "Disiplin, istediğin ile ihtiyacın olan arasındaki köprüdür.",
        "Yolun zorluğu, hedefin değerine işarettir.",
        "Unutma, en karanlık gece bile sonunda sabaha kavuşur.",
        "Başarı bir seçimdir, her gün o seçimi yap.",
        "Konsantrasyonunu kaybetme, hedefe odaklan.",
        "Bir yıl sonra, bugün başladığına memnun olacaksın."
    ]
    
    // Hedef filtreleme için enum
    enum GoalFilter {
        case all
        case completed
        case incomplete
        case priority(DailyGoal.Priority)
    }
    
    init() {
        loadData()
        setupQuoteTimer()
    }
    
    deinit {
        quoteTimer?.invalidate()
    }
    
    // MARK: - Veri Yükleme İşlemleri
    
    func loadData() {
        isLoading = true
        
        // Motivasyon sözünü ayarla
        updateMotivationalQuote()
        
        // Örnek veriler yükle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.loadSampleData()
            self.isLoading = false
        }
    }
    
    // MARK: - Motivasyon Sözü İşlemleri
    
    private func updateMotivationalQuote() {
        let hour = Calendar.current.component(.hour, from: Date())
        let index = hour % motivationalQuotes.count
        self.motivationalQuote = motivationalQuotes[index]
    }
    
    private func setupQuoteTimer() {
        // Önceki timer varsa temizle
        quoteTimer?.invalidate()
        
        // Bir sonraki saat başına kadar kalan süreyi hesapla
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .second], from: now)
        let secondsUntilNextHour = (60 - (components.minute ?? 0)) * 60 - (components.second ?? 0)
        
        // Timer'ı başlat
        quoteTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(secondsUntilNextHour), repeats: false) { [weak self] _ in
            self?.updateMotivationalQuote()
            // Sonraki saatler için her saat başında çalışacak timer'ı ayarla
            self?.setupHourlyTimer()
        }
    }
    
    private func setupHourlyTimer() {
        quoteTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateMotivationalQuote()
        }
    }
    
    // MARK: - Hedef İşlemleri
    
    func toggleGoalCompletion(_ goal: DailyGoal) {
        if let index = todaysGoals.firstIndex(where: { $0.id == goal.id }) {
            todaysGoals[index].isCompleted.toggle()
            
            // Burada veritabanına kaydetme işlemleri yapılabilir
        }
    }
    
    func addGoal(_ goal: DailyGoal) {
        todaysGoals.append(goal)
        
        // Burada veritabanına kaydetme işlemleri yapılabilir
    }
    
    func deleteGoal(_ goal: DailyGoal) {
        todaysGoals.removeAll { $0.id == goal.id }
        
        // Burada veritabanına kaydetme işlemleri yapılabilir
    }
    
    func filteredGoals() -> [DailyGoal] {
        switch selectedGoalFilter {
        case .all:
            return todaysGoals
        case .completed:
            return todaysGoals.filter { $0.isCompleted }
        case .incomplete:
            return todaysGoals.filter { !$0.isCompleted }
        case .priority(let priority):
            return todaysGoals.filter { $0.priority == priority }
        }
    }
    
    // MARK: - Örnek Veri
    
    private func loadSampleData() {
        // Günlük özet
        self.dailySummary = DailyStudySummary(
            date: Date(),
            totalStudyHours: 3.5,
            completedTasks: 7,
            totalTasks: 10,
            mostStudiedSubject: "Matematik"
        )
        
        // Önerilen çalışma konuları
        self.suggestedTopics = [
            StudySuggestion(
                title: "Üçgenler",
                subject: "Geometri",
                reasonForSuggestion: .lowPerformance,
                examType: .tyt,
                difficulty: 4,
                estimatedDuration: 45,
                lastStudied: Date().addingTimeInterval(-7 * 24 * 3600) // 1 hafta önce
            ),
            StudySuggestion(
                title: "Paragraf Soruları",
                subject: "Türkçe",
                reasonForSuggestion: .upcomingExam,
                examType: .tyt,
                difficulty: 3,
                estimatedDuration: 30,
                lastStudied: Date().addingTimeInterval(-2 * 24 * 3600) // 2 gün önce
            ),
            StudySuggestion(
                title: "Türev Uygulamaları",
                subject: "Matematik",
                reasonForSuggestion: .notStudiedRecently,
                examType: .ayt,
                difficulty: 5,
                estimatedDuration: 60,
                lastStudied: Date().addingTimeInterval(-14 * 24 * 3600) // 2 hafta önce
            ),
            StudySuggestion(
                title: "Asitler ve Bazlar",
                subject: "Kimya",
                reasonForSuggestion: .frequentMistakes,
                examType: .tyt,
                difficulty: 4,
                estimatedDuration: 40,
                lastStudied: Date().addingTimeInterval(-5 * 24 * 3600) // 5 gün önce
            ),
            StudySuggestion(
                title: "Oran-Orantı",
                subject: "Matematik",
                reasonForSuggestion: .personalStrength,
                examType: .tyt,
                difficulty: 2,
                estimatedDuration: 25,
                lastStudied: Date().addingTimeInterval(-1 * 24 * 3600) // 1 gün önce
            )
        ]
        
        // Yaklaşan sınavlar
        self.upcomingExams = [
            UpcomingExam(
                title: "TYT Deneme Sınavı",
                date: Date().addingTimeInterval(3 * 24 * 3600), // 3 gün sonra
                location: "Okul Spor Salonu",
                examProvider: "Hızlı Eğitim",
                subjects: ["Türkçe", "Matematik", "Fen Bilimleri", "Sosyal Bilimler"],
                isPractice: true,
                isRegistered: true
            ),
            UpcomingExam(
                title: "AYT Deneme Sınavı",
                date: Date().addingTimeInterval(10 * 24 * 3600), // 10 gün sonra
                location: "İlçe Kültür Merkezi",
                examProvider: "Yıldız Yayınları",
                subjects: ["Matematik", "Fizik", "Kimya", "Biyoloji"],
                isPractice: true,
                isRegistered: true
            ),
            UpcomingExam(
                title: "Özel TYT Kampı",
                date: Date().addingTimeInterval(14 * 24 * 3600), // 14 gün sonra
                location: "Eğitim Akademisi",
                examProvider: "Final Dergisi",
                subjects: ["Tüm Dersler"],
                isPractice: true,
                isRegistered: false
            )
        ]
        
        // Haftalık çalışma verileri
        let weekStartDate = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        self.weeklyData = WeeklyStudyData(
            weekStarting: weekStartDate,
            dailyHours: [4.5, 3.0, 5.2, 2.5, 4.0, 6.0, 3.5], // Son 7 gün
            subjectDistribution: [
                "Matematik": 35,
                "Fizik": 20,
                "Kimya": 15,
                "Biyoloji": 10,
                "Türkçe": 15,
                "Tarih": 5
            ]
        )
        
        // Başarı kartları
        self.recentAchievements = [
            AchievementCard(
                title: "7 Günlük Seri",
                description: "7 gün üst üste çalışma hedefini tamamladın!",
                dateEarned: Date().addingTimeInterval(-24 * 3600), // 1 gün önce
                type: .streak,
                icon: "flame.fill"
            ),
            AchievementCard(
                title: "Matematik Ustası",
                description: "Matematikte 50 soru çözdün!",
                dateEarned: Date().addingTimeInterval(-3 * 24 * 3600), // 3 gün önce
                type: .milestone,
                icon: "medal.fill"
            ),
            AchievementCard(
                title: "Verimli Çalışma",
                description: "Pomodoro tekniğiyle 10 saat çalıştın!",
                dateEarned: Date().addingTimeInterval(-5 * 24 * 3600), // 5 gün önce
                type: .consistency,
                icon: "clock.fill"
            )
        ]
        
        // Bugünün hedefleri
        self.todaysGoals = [
            DailyGoal(
                title: "Türkçe paragraf çöz",
                subject: "Türkçe",
                isCompleted: true,
                priority: .high,
                deadline: Date().addingTimeInterval(6 * 3600), // 6 saat sonra
                createdAt: Date().addingTimeInterval(-24 * 3600) // 1 gün önce
            ),
            DailyGoal(
                title: "Türev formüllerini tekrar et",
                subject: "Matematik",
                isCompleted: false,
                priority: .medium,
                deadline: nil,
                createdAt: Date().addingTimeInterval(-2 * 24 * 3600) // 2 gün önce
            ),
            DailyGoal(
                title: "Kimya denemesindeki hataları incele",
                subject: "Kimya",
                isCompleted: false,
                priority: .high,
                deadline: Date().addingTimeInterval(9 * 3600), // 9 saat sonra
                createdAt: Date().addingTimeInterval(-12 * 3600) // 12 saat önce
            ),
            DailyGoal(
                title: "Mobil uygulama üzerinden 5 soru çöz",
                subject: nil,
                isCompleted: true,
                priority: .low,
                deadline: nil,
                createdAt: Date().addingTimeInterval(-3 * 3600) // 3 saat önce
            ),
            DailyGoal(
                title: "Fizik formüllerini gözden geçir",
                subject: "Fizik",
                isCompleted: false,
                priority: .medium,
                deadline: Date().addingTimeInterval(12 * 3600), // 12 saat sonra
                createdAt: Date().addingTimeInterval(-6 * 3600) // 6 saat önce
            )
        ]
        
        // Çalışma arkadaşları aktiviteleri
        self.buddyActivities = [
            StudyBuddyActivity(
                friendName: "Ahmet Yılmaz",
                avatarURL: nil,
                activityType: .studiedHours,
                subject: "Fizik",
                timestamp: Date().addingTimeInterval(-30 * 60) // 30 dakika önce
            ),
            StudyBuddyActivity(
                friendName: "Ayşe Kara",
                avatarURL: nil,
                activityType: .completedTask,
                subject: "Matematik",
                timestamp: Date().addingTimeInterval(-2 * 3600) // 2 saat önce
            ),
            StudyBuddyActivity(
                friendName: "Mehmet Demir",
                avatarURL: nil,
                activityType: .reachedMilestone,
                subject: nil,
                timestamp: Date().addingTimeInterval(-5 * 3600) // 5 saat önce
            ),
            StudyBuddyActivity(
                friendName: "Zeynep Yıldız",
                avatarURL: nil,
                activityType: .sharedNote,
                subject: "Türkçe",
                timestamp: Date().addingTimeInterval(-1 * 24 * 3600) // 1 gün önce
            )
        ]
    }
}
