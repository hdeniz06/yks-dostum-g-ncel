import Foundation
import Combine

class DashboardViewModel: BaseViewModelImpl {
    @Published var welcomeMessage: String = ""
    @Published var todoItems: [TodoItem] = []
    @Published var studyStats: DashboardStudyStats = DashboardStudyStats()
    @Published var nextExamDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadDashboardData()
    }
    
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
    
    // Timer'ı saklayacak değişken
    private var quoteTimer: Timer?
    
    func loadDashboardData() {
        isLoading = true
        
        // Motivasyon sözünü ayarla
        updateMotivationalQuote()
        
        // Saat başı değişmesi için timer'ı ayarla
        setupQuoteTimer()
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Sample todo items
            self.todoItems = [
                TodoItem(id: UUID(), title: "TYT Matematik Konuları", isCompleted: false),
                TodoItem(id: UUID(), title: "AYT Fizik Testleri", isCompleted: true),
                TodoItem(id: UUID(), title: "Türkçe Paragraf Çalışması", isCompleted: false),
                TodoItem(id: UUID(), title: "Deneme Sınavı Analizi", isCompleted: false)
            ]
            
            // Sample study stats
            self.studyStats = DashboardStudyStats(
                dailyStudyHours: 4.5,
                weeklyStudyHours: 28.5,
                completedTopics: 42,
                totalTopics: 120
            )
            
            // Next YKS exam date (sample)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.nextExamDate = dateFormatter.date(from: "15/06/2026")
            
            self.isLoading = false
        }
    }
    
    // Motivasyon sözünü güncelle
    private func updateMotivationalQuote() {
        // Saat değerine göre sabit bir söz seçimi (saat başı değişmesi için)
        let hour = Calendar.current.component(.hour, from: Date())
        let index = hour % motivationalQuotes.count
        self.welcomeMessage = motivationalQuotes[index]
    }
    
    // Timer'ı ayarla
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
    
    // Saatlik timer'ı ayarla
    private func setupHourlyTimer() {
        quoteTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateMotivationalQuote()
        }
    }
    
    // ViewModel temizlendiğinde timer'ı durdur
    deinit {
        quoteTimer?.invalidate()
    }
    
    func toggleTodoItem(_ id: UUID) {
        if let index = todoItems.firstIndex(where: { $0.id == id }) {
            todoItems[index].isCompleted.toggle()
            // In a real app, you would save this change to a database
        }
    }
    
    func addTodoItem(title: String) {
        let newItem = TodoItem(id: UUID(), title: title, isCompleted: false)
        todoItems.append(newItem)
        // In a real app, you would save this to a database
    }
}

// Models used by the Dashboard
struct TodoItem: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}

struct DashboardStudyStats {
    var dailyStudyHours: Double = 0
    var weeklyStudyHours: Double = 0
    var completedTopics: Int = 0
    var totalTopics: Int = 0
    
    var topicCompletionPercentage: Double {
        guard totalTopics > 0 else { return 0 }
        return Double(completedTopics) / Double(totalTopics) * 100
    }
}
