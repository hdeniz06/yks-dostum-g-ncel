import Foundation
import SwiftUI
import Combine

class KonuTakibiViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var categories: [KonuKategori] = []
    @Published var selectedCategory: KonuKategori?
    @Published var showingAddSubjectSheet = false
    @Published var showingAddCategorySheet = false
    @Published var newSubjectName = ""
    @Published var newSubjectTopics = ""
    @Published var newSubjectCompleted = ""
    @Published var newSubjectNotes = ""
    @Published var selectedExamType: ExamType = ExamType.tyt
    @Published var newCategoryName = ""
    @Published var searchText = ""
    @Published var sortOption: SortOption = .name
    @Published var filterOption: FilterOption = .all
    @Published var selectedSubject: KonuTakibi? = nil
    @Published var showingEditSubjectSheet = false
    
    // MARK: - Sort & Filter Options
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "İsme Göre"
        case progress = "İlerlemeye Göre"
        case lastStudied = "Son Çalışmaya Göre"
        
        var id: String { self.rawValue }
    }
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "Tümü"
        case inProgress = "Devam Edenler"
        case completed = "Tamamlananlar"
        
        var id: String { self.rawValue }
    }
    
    // MARK: - Init
    init() {
        loadData()
    }
    
    // MARK: - Data Operations
    func loadData() {
        // MARK: - Test amaçlı örnek veriler (kolayca kaldırılabilir)
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "showSampleData") || true { // Kaldırmak için 'true' kısmını silin
            loadSampleData()
            return
        }
        #endif
        
        if let data = UserDefaults.standard.data(forKey: "konuKategoriler") {
            if let decoded = try? JSONDecoder().decode([KonuKategori].self, from: data) {
                self.categories = decoded
                return
            }
        }
        
        // Default categories if no data exists
        self.categories = YKSKategoriler.createDefaultCategories()
        saveData()
    }
    
    // MARK: - Örnek Veriler (Test için)
    private func loadSampleData() {
        // Matematik kategorisi
        var matematik = KonuKategori(name: "Matematik")
        matematik.subjects = [
            KonuTakibi(name: "Temel Kavramlar", examType: .tyt, totalTopics: 5, completedTopics: 4, lastStudyDate: Date().addingTimeInterval(-3600*24*2), notes: "Mutlak değer konusuna tekrar çalışmalıyım"),
            KonuTakibi(name: "Sayı Basamakları", examType: .tyt, totalTopics: 3, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*5)),
            KonuTakibi(name: "Bölünebilme Kuralları", examType: .tyt, totalTopics: 4, completedTopics: 2, lastStudyDate: Date(), notes: "Asal çarpanlara ayırma tekniklerini unutma"),
            KonuTakibi(name: "EBOB-EKOK", examType: .tyt, totalTopics: 2, completedTopics: 0),
            KonuTakibi(name: "Rasyonel Sayılar", examType: .tyt, totalTopics: 3, completedTopics: 1, lastStudyDate: Date().addingTimeInterval(-3600*24*8)),
            KonuTakibi(name: "Türev", examType: .ayt, totalTopics: 8, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*1), notes: "Zincir kuralına daha fazla örnek çöz"),
            KonuTakibi(name: "İntegral", examType: .ayt, totalTopics: 6, completedTopics: 0)
        ]
        
        // Fizik kategorisi
        var fizik = KonuKategori(name: "Fizik")
        fizik.subjects = [
            KonuTakibi(name: "Hareket", examType: .tyt, totalTopics: 4, completedTopics: 4, lastStudyDate: Date().addingTimeInterval(-3600*24*3)),
            KonuTakibi(name: "Kuvvet ve Hareket", examType: .tyt, totalTopics: 5, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*1), notes: "Newton kanunlarına tekrar bak"),
            KonuTakibi(name: "İş ve Enerji", examType: .tyt, totalTopics: 3, completedTopics: 1, lastStudyDate: Date()),
            KonuTakibi(name: "Elektrik", examType: .ayt, totalTopics: 7, completedTopics: 2, lastStudyDate: Date().addingTimeInterval(-3600*24*4))
        ]
        
        // Türkçe kategorisi
        var turkce = KonuKategori(name: "Türkçe")
        turkce.subjects = [
            KonuTakibi(name: "Sözcükte Anlam", examType: .tyt, totalTopics: 5, completedTopics: 5, lastStudyDate: Date().addingTimeInterval(-3600*24*7)),
            KonuTakibi(name: "Cümlede Anlam", examType: .tyt, totalTopics: 6, completedTopics: 4, lastStudyDate: Date().addingTimeInterval(-3600*24*2), notes: "Örtülü anlam konusuna ağırlık ver"),
            KonuTakibi(name: "Paragraf", examType: .tyt, totalTopics: 8, completedTopics: 6, lastStudyDate: Date()),
            KonuTakibi(name: "Dil Bilgisi", examType: .tyt, totalTopics: 10, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*1))
        ]
        
        // İngilizce kategorisi
        var ingilizce = KonuKategori(name: "İngilizce")
        ingilizce.subjects = [
            KonuTakibi(name: "Tenses", examType: .ydt, totalTopics: 12, completedTopics: 8, lastStudyDate: Date().addingTimeInterval(-3600*24*3), notes: "Perfect tenses konusunu detaylı çalış"),
            KonuTakibi(name: "Modals", examType: .ydt, totalTopics: 5, completedTopics: 4, lastStudyDate: Date().addingTimeInterval(-3600*24*6)),
            KonuTakibi(name: "Conditionals", examType: .ydt, totalTopics: 4, completedTopics: 2, lastStudyDate: Date()),
            KonuTakibi(name: "Passives", examType: .ydt, totalTopics: 3, completedTopics: 1, lastStudyDate: Date().addingTimeInterval(-3600*24*4))
        ]
        
        // Kimya kategorisi
        var kimya = KonuKategori(name: "Kimya")
        kimya.subjects = [
            KonuTakibi(name: "Atomun Yapısı", examType: .tyt, totalTopics: 4, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*5)),
            KonuTakibi(name: "Periyodik Cetvel", examType: .tyt, totalTopics: 3, completedTopics: 3, lastStudyDate: Date().addingTimeInterval(-3600*24*8)),
            KonuTakibi(name: "Kimyasal Bağlar", examType: .tyt, totalTopics: 5, completedTopics: 2, lastStudyDate: Date().addingTimeInterval(-3600*24*2)),
            KonuTakibi(name: "Organik Kimya", examType: .ayt, totalTopics: 8, completedTopics: 1, lastStudyDate: Date(), notes: "Fonksiyonel grupları tekrar et")
        ]
        
        // Biyoloji kategorisi (boş kategori örneği)
        let biyoloji = KonuKategori(name: "Biyoloji")
        
        // Tarih kategorisi (çok az konu içeren kategori örneği)
        var tarih = KonuKategori(name: "Tarih")
        tarih.subjects = [
            KonuTakibi(name: "İlk Türk Devletleri", examType: .tyt, totalTopics: 6, completedTopics: 0)
        ]
        
        // Tüm kategorileri listeye ekle
        self.categories = [matematik, fizik, turkce, ingilizce, kimya, biyoloji, tarih]
        
        // İlk kategoriyi seç
        self.selectedCategory = matematik
        
        // Kaydedelim ki birkaç kez açılıp kapanırsa veriler korunsun
        saveData()
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "konuKategoriler")
        }
    }
    
    // MARK: - Category Operations
    func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newCategory = KonuKategori(name: newCategoryName, subjects: [])
        categories.append(newCategory)
        newCategoryName = ""
        saveData()
    }
    
    func removeCategory(at indexSet: IndexSet) {
        categories.remove(atOffsets: indexSet)
        saveData()
    }
    
    func removeCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        saveData()
    }
    
    // MARK: - Subject Operations
    func addSubject(to category: KonuKategori) {
        guard !newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let totalTopics = Int(newSubjectTopics) ?? 1
        let completedTopics = Int(newSubjectCompleted) ?? 0
        
        let newSubject = KonuTakibi(
            name: newSubjectName,
            examType: selectedExamType,
            totalTopics: totalTopics,
            completedTopics: completedTopics,
            lastStudyDate: Date(),
            notes: newSubjectNotes
        )
        
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].subjects.append(newSubject)
        }
        
        // Reset form fields
        resetNewSubjectForm()
        saveData()
    }
    
    func incrementCompletedTopics(for subject: KonuTakibi, in category: KonuKategori) {
        if let catIndex = categories.firstIndex(where: { $0.id == category.id }),
           let subjectIndex = categories[catIndex].subjects.firstIndex(where: { $0.id == subject.id }) {
            if categories[catIndex].subjects[subjectIndex].completedTopics < categories[catIndex].subjects[subjectIndex].totalTopics {
                categories[catIndex].subjects[subjectIndex].completedTopics += 1
                categories[catIndex].subjects[subjectIndex].lastStudyDate = Date()
                saveData()
            }
        }
    }
    
    func decrementCompletedTopics(for subject: KonuTakibi, in category: KonuKategori) {
        if let catIndex = categories.firstIndex(where: { $0.id == category.id }),
           let subjectIndex = categories[catIndex].subjects.firstIndex(where: { $0.id == subject.id }) {
            if categories[catIndex].subjects[subjectIndex].completedTopics > 0 {
                categories[catIndex].subjects[subjectIndex].completedTopics -= 1
                categories[catIndex].subjects[subjectIndex].lastStudyDate = Date()
                saveData()
            }
        }
    }
    
    func updateSubject(_ subject: KonuTakibi, in category: KonuKategori, with updatedSubject: KonuTakibi) {
        if let catIndex = categories.firstIndex(where: { $0.id == category.id }),
           let subjectIndex = categories[catIndex].subjects.firstIndex(where: { $0.id == subject.id }) {
            categories[catIndex].subjects[subjectIndex] = updatedSubject
            saveData()
        }
    }
    
    func deleteSubject(_ subject: KonuTakibi, from category: KonuKategori) {
        if let catIndex = categories.firstIndex(where: { $0.id == category.id }) {
            categories[catIndex].subjects.removeAll { $0.id == subject.id }
            saveData()
        }
    }
    
    func resetNewSubjectForm() {
        newSubjectName = ""
        newSubjectTopics = ""
        newSubjectCompleted = ""
        newSubjectNotes = ""
        selectedExamType = ExamType.tyt
    }
    
    func saveEditedSubject() {
        guard let selectedSubject = selectedSubject else { return }
        if let catIndex = categories.firstIndex(where: { $0.subjects.contains(where: { $0.id == selectedSubject.id }) }) {
            if let subIndex = categories[catIndex].subjects.firstIndex(where: { $0.id == selectedSubject.id }) {
                categories[catIndex].subjects[subIndex] = selectedSubject
                saveData()
            }
        }
    }
    
    // MARK: - Filtered & Sorted Results
    func filteredSubjectsForCategory(_ category: KonuKategori) -> [KonuTakibi] {
        var subjects = category.subjects
        
        // Apply search filter if there's search text
        if !searchText.isEmpty {
            subjects = subjects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply selected filter
        switch filterOption {
        case .inProgress:
            subjects = subjects.filter { !$0.isCompleted }
        case .completed:
            subjects = subjects.filter { $0.isCompleted }
        case .all:
            break
        }
        
        // Apply selected sort
        switch sortOption {
        case .name:
            subjects.sort { $0.name < $1.name }
        case .progress:
            subjects.sort { $0.progress > $1.progress }
        case .lastStudied:
            subjects.sort { 
                guard let date1 = $0.lastStudyDate else { return false }
                guard let date2 = $1.lastStudyDate else { return true }
                return date1 > date2
            }
        }
        
        return subjects
    }
}
