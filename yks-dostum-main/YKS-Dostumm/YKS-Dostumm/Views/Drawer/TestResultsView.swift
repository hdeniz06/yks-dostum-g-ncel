import SwiftUI

struct TestResultsView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @State private var showingAddTest = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filter and time range
            TestResultsHeaderView(
                viewModel: viewModel,
                showingAddTest: $showingAddTest
            )
            .background(Color(UIColor.secondarySystemBackground))
            
            // Tab Selection
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Genel Bakış").tag(0)
                Text("Denemeler").tag(1)
                Text("Ders Analizi").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            
            // Content Card
            Group {
                if selectedTab == 0 {
                    OverviewTabView(viewModel: viewModel)
                } else if selectedTab == 1 {
                    TestsListTabView(viewModel: viewModel, showingAddTest: $showingAddTest)
                } else {
                    SubjectAnalysisTabView(viewModel: viewModel)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlayView()
            }
        }
        .sheet(isPresented: $showingAddTest) {
            AddTestResultView { result in
                viewModel.addTestResult(result)
                showingAddTest = false
            }
        }
        .onChange(of: viewModel.selectedFilter) { _, _ in
            // Reset to overview tab when filter changes
            selectedTab = 0
        }
    }
}

// MARK: - Header View
struct TestResultsHeaderView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @Binding var showingAddTest: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Deneme Sonuçları")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingAddTest = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.blue))
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Filter Tabs (all moved to right)
            HStack(spacing: 0) {
                ForEach([TestFilter.tyt, .ayt, .ydt, .all], id: \.self) { filter in
                    Button(action: {
                        viewModel.selectedFilter = filter
                        viewModel.updateChartData()
                        viewModel.calculateProgressData()
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(viewModel.selectedFilter == filter ? .blue : .gray)
                    .background(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(viewModel.selectedFilter == filter ? Color.blue : Color.clear)
                                .frame(height: 3)
                        }
                    )
                }
            }
            
            // Time Range Picker
            Picker("Zaman Aralığı", selection: $viewModel.selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: viewModel.selectedTimeRange) { _, _ in
                viewModel.calculateProgressData()
            }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlayView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 80, height: 80)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .edgesIgnoringSafeArea(.all)
    }
}

struct OverviewTabView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @State private var animateProgress = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Summary Card
                VStack(spacing: 15) {
                    HStack {
                        Text("Performans Özeti")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        VStack(alignment: .trailing) {
                            if let lastName = viewModel.filteredTestResults.first?.name {
                                Text(lastName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("\(viewModel.progressData.testCount) Deneme")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    
                    // Progress Circle
                    HStack(spacing: 25) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: animateProgress ? min(CGFloat(viewModel.progressData.averagePercentage / 100), 1.0) : 0)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: animateProgress)
                            
                            VStack(spacing: 5) {
                                Text(String(format: "%.1f", viewModel.progressData.averagePercentage))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            // Average Net Score
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text("Ortalama Net")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(String(format: "%.1f", viewModel.progressData.averageNetScore))
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            // Improvement
                            HStack {
                                Image(systemName: viewModel.progressData.improvement >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                                    .foregroundColor(viewModel.progressData.improvement >= 0 ? .green : .red)
                                
                                VStack(alignment: .leading) {
                                    Text("Gelişim")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(String(format: "%+.1f%%", viewModel.progressData.improvement))
                                        .font(.headline)
                                        .foregroundColor(viewModel.progressData.improvement >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Best & Worst Subjects
                    if !viewModel.progressData.bestSubject.isEmpty {
                        HStack(spacing: 20) {
                            // Best Subject
                            VStack(spacing: 5) {
                                Text("En İyi Ders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(viewModel.progressData.bestSubject)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(String(format: "%.1f", viewModel.progressData.bestSubjectScore))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.1))
                                )
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Worst Subject
                            VStack(spacing: 5) {
                                Text("Geliştirilmesi Gereken")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(viewModel.progressData.worstSubject)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(String(format: "%.1f", viewModel.progressData.worstSubjectScore))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red.opacity(0.1))
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Performance Chart
                if !viewModel.chartData.isEmpty {
                    EnhancedPerformanceChartView(data: viewModel.chartData)
                }
                
                // Motivational Message
                MotivationalCardView(progressData: viewModel.progressData)
            }
            .padding()
        }
        .onAppear {
            // Trigger animation when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateProgress = true
            }
        }
    }
}

struct EnhancedPerformanceChartView: View {
    let data: [SubjectScore]
    @State private var animateBar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ders Performansı")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Bar Chart
            VStack(spacing: 12) {
                ForEach(data.prefix(5)) { item in
                    HStack {
                        Text(item.subject)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background bar
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .cornerRadius(5)
                                
                                // Value bar
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(5)
                                    .frame(width: animateBar ? min(CGFloat(item.score / 40) * geometry.size.width, geometry.size.width) : 0)
                                    .animation(.easeInOut(duration: 1.0), value: animateBar)
                                
                                // Value label
                                Text(String(format: "%.1f", item.score))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                    .opacity(animateBar ? 1 : 0)
                                    .animation(.easeInOut(duration: 1.0), value: animateBar)
                            }
                        }
                        .frame(height: 25)
                    }
                }
            }
            
            // Legend
            HStack {
                Text("0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("20")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("40")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 80)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            // Trigger animation when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateBar = true
            }
        }
    }
}

struct MotivationalCardView: View {
    let progressData: ProgressData
    
    var motivationalMessage: String {
        if progressData.improvement > 5 {
            return "Harika ilerleme kaydediyorsun! Böyle devam et, hedefine her geçen gün yaklaşıyorsun."
        } else if progressData.improvement > 0 {
            return "İlerleme kaydediyorsun! Çalışmalarının karşılığını almaya başladın."
        } else if progressData.improvement == 0 {
            return "Performansın sabit gidiyor. Biraz daha çalışarak sonuçlarını iyileştirebilirsin!"
        } else {
            return "Endişelenme, her öğrenci zaman zaman düşüşler yaşayabilir. Eksik konulara odaklanarak tekrar yükselişe geçebilirsin!"
        }
    }
    
    var tipMessage: String {
        if !progressData.worstSubject.isEmpty {
            return "\(progressData.worstSubject) dersine biraz daha zaman ayırarak genel performansını artırabilirsin."
        } else {
            return "Düzenli çalışma programı oluşturarak performansını artırabilirsin."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Motivasyon & İpuçları")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(motivationalMessage)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.vertical, 5)
            
            HStack {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text(tipMessage)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PerformanceChartView: View {
    let data: [SubjectScore]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ders Performansı")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Bar Chart
            VStack(spacing: 12) {
                ForEach(data) { item in
                    HStack {
                        Text(item.subject)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 20)
                                    .opacity(0.2)
                                    .foregroundColor(.gray)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(item.score / 40) * geometry.size.width, geometry.size.width), height: 20)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                                
                                Text(String(format: "%.1f", item.score))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                            }
                        }
                        .frame(height: 20)
                    }
                }
            }
            
            // Legend
            HStack {
                Text("0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("40")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 80)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TestResultCardView: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.name)
                        .font(.headline)
                    
                    Text(result.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(result.examType.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(result.examType == .tyt ? Color.blue.opacity(0.2) : result.examType == .ayt ? Color.purple.opacity(0.2) : Color.green.opacity(0.2))
                    )
                    .foregroundColor(result.examType == .tyt ? .blue : result.examType == .ayt ? .purple : .green)
            }
            
            Divider()
            
            // Score Summary
            HStack(spacing: 20) {
                // Net Score
                VStack {
                    Text(String(format: "%.1f", result.netScore))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Net")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Correct
                VStack {
                    Text("\(result.correctAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("Doğru")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Wrong
                VStack {
                    Text("\(result.wrongAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text("Yanlış")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Empty
                VStack {
                    Text("\(result.emptyAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Boş")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Percentage
                VStack {
                    Text(String(format: "%.1f%%", result.scorePercentage))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.purple)
                    
                    Text("Başarı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Subject Scores
            VStack(alignment: .leading, spacing: 10) {
                Text("Ders Bazlı Sonuçlar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(result.subjectScores) { score in
                        HStack {
                            Text(score.subject)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", score.score))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddTestResultView: View {
    let onAdd: (TestResult) -> Void
    
    @State private var name: String = ""
    @State private var examType: ExamType = .tyt
    @State private var date: Date = Date()
    @State private var totalQuestions: Int = 120
    @State private var correctAnswers: Int = 0
    @State private var wrongAnswers: Int = 0
    var emptyAnswers: Int {
        totalQuestions - (correctAnswers + wrongAnswers)
    }
    
    @State private var subjectCorrectInputs: [String: String] = [:]
    @State private var subjectWrongInputs: [String: String] = [:]
    @State private var subjectEmptyInputs: [String: String] = [:]
    private var subjects: [String] {
        switch examType {
        case .tyt:
            return ["Türkçe", "Matematik", "Coğrafya", "Fizik", "Kimya", "Biyoloji", "Tarih", "Felsefe", "Din Kültürü ve Ahlak Bilgisi"]
        case .ayt:
            return [
                "Türk Dili ve Edebiyatı",
                "Tarih/1",
                "Coğrafya/1",
                "Tarih/2",
                "Coğrafya/2",
                "Felsefe Grubu",
                "Din Kültürü ve Ahlak Bilgisi",
                "Matematik",
                "Fizik",
                "Kimya",
                "Biyoloji"
            ]
        case .ydt:
            return [
                "Kelime Bilgisi",
                "Dilbilgisi",
                "Cloze Test",
                "Cümleyi Tamamlama",
                "İngilizce Cümlenin Türkçe Karşılığını Bulma",
                "Türkçe Cümlenin İngilizce Karşılığını Bulma",
                "Paragraf",
                "Anlamca Yakın Cümleyi Bulma",
                "Paragrafta Anlam Bütünlüğünü Sağlayacak Cümleyi Bulma",
                "Verilen Durumda Söylenecek İfadeyi Bulma",
                "Diyalog Tamamlama",
                "Anlam Bütünlüğünü Bozan Cümleyi Bulma"
            ]
        default:
            return []
        }
    }
    private var questionLimits: [String: Int] {
        switch examType {
        case .tyt:
            return [
                "Türkçe": 40,
                "Matematik": 40,
                "Coğrafya": 5,
                "Fizik": 7,
                "Kimya": 7,
                "Biyoloji": 6,
                "Tarih": 5,
                "Felsefe": 5,
                "Din Kültürü ve Ahlak Bilgisi": 5
            ]
        case .ayt:
            return [
                "Türk Dili ve Edebiyatı": 24,
                "Tarih/1": 10,
                "Coğrafya/1": 6,
                "Tarih/2": 11,
                "Coğrafya/2": 11,
                "Felsefe Grubu": 12,
                "Din Kültürü ve Ahlak Bilgisi": 6,
                "Matematik": 40,
                "Fizik": 14,
                "Kimya": 13,
                "Biyoloji": 13
            ]
        case .ydt:
            return [
                "Kelime Bilgisi": 5,
                "Dilbilgisi": 10,
                "Cloze Test": 5,
                "Cümleyi Tamamlama": 8,
                "İngilizce Cümlenin Türkçe Karşılığını Bulma": 6,
                "Türkçe Cümlenin İngilizce Karşılığını Bulma": 6,
                "Paragraf": 15,
                "Anlamca Yakın Cümleyi Bulma": 5,
                "Paragrafta Anlam Bütünlüğünü Sağlayacak Cümleyi Bulma": 5,
                "Verilen Durumda Söylenecek İfadeyi Bulma": 5,
                "Diyalog Tamamlama": 5,
                "Anlam Bütünlüğünü Bozan Cümleyi Bulma": 5
            ]
        default:
            return [:]
        }
    }
    private func subjectNet(_ subject: String) -> Double {
        let c = Int(subjectCorrectInputs[subject] ?? "") ?? 0
        let w = Int(subjectWrongInputs[subject] ?? "") ?? 0
        return Double(c) - Double(w) * 0.25
    }
    private var totalNet: Double {
        subjects.reduce(0) { $0 + subjectNet($1) }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var netScore: Double {
        return Double(correctAnswers) - (Double(wrongAnswers) * 0.25)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Deneme Bilgileri")) {
                    TextField("Deneme Adı", text: $name)
                    
                    Picker("Sınav Türü", selection: $examType) {
                        ForEach(ExamType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Ders Doğru/Yanlış")) {
                    ForEach(subjects, id: \.self) { subject in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(subject)
                                Spacer()
                                TextField("D", text: Binding(
                                    get: { subjectCorrectInputs[subject] ?? "" },
                                    set: { value in
                                        let intVal = Int(value) ?? 0
                                        let limit = questionLimits[subject] ?? Int.max
                                        subjectCorrectInputs[subject] = String(min(intVal, limit))
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 40)
                                .onChange(of: subjectCorrectInputs[subject] ?? "") { newValue in
                                    let limit = questionLimits[subject] ?? Int.max
                                    if let v = Int(newValue), v > limit {
                                        subjectCorrectInputs[subject] = String(limit)
                                    }
                                }
                                
                                TextField("Y", text: Binding(
                                    get: { subjectWrongInputs[subject] ?? "" },
                                    set: { value in
                                        let intVal = Int(value) ?? 0
                                        let limit = questionLimits[subject] ?? Int.max
                                        subjectWrongInputs[subject] = String(min(intVal, limit))
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 40)
                                .onChange(of: subjectWrongInputs[subject] ?? "") { newValue in
                                    let limit = questionLimits[subject] ?? Int.max
                                    if let v = Int(newValue), v > limit {
                                        subjectWrongInputs[subject] = String(limit)
                                    }
                                }
                                
                                TextField("B", text: Binding(
                                    get: { subjectEmptyInputs[subject] ?? "" },
                                    set: { value in
                                        let intVal = Int(value) ?? 0
                                        let limit = questionLimits[subject] ?? Int.max
                                        subjectEmptyInputs[subject] = String(min(intVal, limit))
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 40)
                                .onChange(of: subjectEmptyInputs[subject] ?? "") { newValue in
                                    let limit = questionLimits[subject] ?? Int.max
                                    if let v = Int(newValue), v > limit {
                                        subjectEmptyInputs[subject] = String(limit)
                                    }
                                }
                            }
                            Text("Net: \(String(format: "%.2f", subjectNet(subject)))")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    HStack {
                        Text("Toplam Net")
                        Spacer()
                        Text(String(format: "%.2f", totalNet))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Deneme Sonucu Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    // Clamp each subject input to its max question limit
                    subjects.forEach { subject in
                        let limit = questionLimits[subject] ?? Int.max
                        if let c = Int(subjectCorrectInputs[subject] ?? ""), c > limit {
                            subjectCorrectInputs[subject] = String(limit)
                        }
                        if let w = Int(subjectWrongInputs[subject] ?? ""), w > limit {
                            subjectWrongInputs[subject] = String(limit)
                        }
                        if let e = Int(subjectEmptyInputs[subject] ?? ""), e > limit {
                            subjectEmptyInputs[subject] = String(limit)
                        }
                    }
                    // Build subject scores and totals
                    let scores = subjects.map { subject -> SubjectScore in
                        let net = subjectNet(subject)
                        return SubjectScore(subject: subject, score: net)
                    }
                    let netTotal = scores.reduce(0) { $0 + $1.score }
                    let correctSum = subjects.reduce(0) { $0 + (Int(subjectCorrectInputs[$1] ?? "") ?? 0) }
                    let wrongSum = subjects.reduce(0) { $0 + (Int(subjectWrongInputs[$1] ?? "") ?? 0) }
                    let emptySum = subjects.reduce(0) { $0 + (Int(subjectEmptyInputs[$1] ?? "") ?? 0) }
                    let totalQ = questionLimits.values.reduce(0) { $0 + $1 }
                    let result = TestResult(
                        id: UUID(),
                        name: name.isEmpty ? "Yeni Deneme" : name,
                        examType: examType,
                        date: date,
                        totalQuestions: totalQ,
                        correctAnswers: correctSum,
                        wrongAnswers: wrongSum,
                        emptyAnswers: emptySum,
                        netScore: netTotal,
                        subjectScores: scores
                    )
                    onAdd(result)
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct TestsListTabView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @Binding var showingAddTest: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Test Results List
                if !viewModel.filteredTestResults.isEmpty {
                    ForEach(viewModel.filteredTestResults) { result in
                        EnhancedTestResultCardView(result: result)
                    }
                } else {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 40)
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Henüz deneme sonucu yok")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("İlk deneme sonucunu ekleyerek performansını takip etmeye başla")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showingAddTest = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Deneme Sonucu Ekle")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                }
            }
            .padding()
        }
    }
}

struct EnhancedTestResultCardView: View {
    let result: TestResult
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.name)
                        .font(.headline)
                    
                    Text(result.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(result.examType.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(result.examType == .tyt ? Color.blue.opacity(0.2) : result.examType == .ayt ? Color.purple.opacity(0.2) : Color.green.opacity(0.2))
                    )
                    .foregroundColor(result.examType == .tyt ? .blue : result.examType == .ayt ? .purple : .green)
            }
            
            Divider()
            
            // Score Summary
            HStack(spacing: 20) {
                // Net Score with circular progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(result.scorePercentage / 100), 1.0))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", result.netScore))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Net")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Correct
                VStack {
                    Text("\(result.correctAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("Doğru")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Wrong
                VStack {
                    Text("\(result.wrongAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text("Yanlış")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Empty
                VStack {
                    Text("\(result.emptyAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Boş")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Percentage
                VStack {
                    Text(String(format: "%.1f%%", result.scorePercentage))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.purple)
                    
                    Text("Başarı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Expand/Collapse Button
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Detayları Gizle" : "Detayları Göster")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 5)
            }
            
            // Subject Scores (Expandable)
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ders Bazlı Sonuçlar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(result.subjectScores) { score in
                            HStack {
                                Text(score.subject)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", score.score))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SubjectAnalysisTabView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @State private var selectedSubject: String = ""
    
    var uniqueSubjects: [String] {
        var subjects = Set<String>()
        for result in viewModel.filteredTestResults {
            for score in result.subjectScores {
                subjects.insert(score.subject)
            }
        }
        return Array(subjects).sorted()
    }
    
    var subjectData: [SubjectDataPoint] {
        guard !selectedSubject.isEmpty else { return [] }
        
        var dataPoints: [SubjectDataPoint] = []
        let sortedResults = viewModel.filteredTestResults.sorted { $0.date < $1.date }
        
        for result in sortedResults {
            if let score = result.subjectScores.first(where: { $0.subject == selectedSubject }) {
                dataPoints.append(SubjectDataPoint(
                    date: result.date,
                    score: score.score,
                    testName: result.name
                ))
            }
        }
        
        return dataPoints
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Subject Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ders Seçin")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(uniqueSubjects, id: \.self) { subject in
                                Button(action: {
                                    selectedSubject = subject
                                }) {
                                    Text(subject)
                                        .font(.subheadline)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedSubject == subject ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedSubject == subject ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if !selectedSubject.isEmpty {
                    // Subject Progress Chart
                    if !subjectData.isEmpty {
                        SubjectProgressChartView(
                            data: subjectData,
                            subject: selectedSubject,
                            trend: viewModel.getSubjectTrend(for: selectedSubject)
                        )
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    } else {
                        Text("Bu ders için henüz veri bulunmuyor")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Subject Recommendations
                    SubjectRecommendationsView(subject: selectedSubject)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                } else if !uniqueSubjects.isEmpty {
                    Text("Analiz için bir ders seçin")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                } else {
                    Text("Henüz deneme sonucu yok")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                }
            }
            .padding()
        }
        .onAppear {
            if !uniqueSubjects.isEmpty && selectedSubject.isEmpty {
                selectedSubject = uniqueSubjects[0]
            }
        }
    }
}

struct SubjectDataPoint {
    let date: Date
    let score: Double
    let testName: String
}

struct SubjectProgressChartView: View {
    let data: [SubjectDataPoint]
    let subject: String
    let trend: SubjectTrend
    
    @State private var showingPoints = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(subject) Performansı")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack {
                    Image(systemName: trend.icon)
                        .foregroundColor(Color(trend.color))
                    
                    Text(trendText)
                        .font(.caption)
                        .foregroundColor(Color(trend.color))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(trend.color).opacity(0.1))
                )
            }
            
            // Line Chart
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    
                    // Line
                    Path { path in
                        guard !data.isEmpty else { return }
                        
                        let maxScore = max(40.0, data.map { $0.score }.max() ?? 40.0)
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        let stepX = width / CGFloat(data.count - 1)
                        
                        let points = data.enumerated().map { (index, point) -> CGPoint in
                            let x = CGFloat(index) * stepX
                            let y = height - CGFloat(point.score / maxScore) * height
                            return CGPoint(x: x, y: y)
                        }
                        
                        path.move(to: points[0])
                        
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                    }
                    .trim(from: 0, to: showingPoints ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .rotationEffect(.degrees(0))
                    .animation(.easeInOut(duration: 1.0), value: showingPoints)
                    
                    // Data points
                    ForEach(0..<data.count, id: \.self) { index in
                        let maxScore = max(40.0, data.map { $0.score }.max() ?? 40.0)
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        let stepX = width / CGFloat(data.count - 1)
                        let x = CGFloat(index) * stepX
                        let y = height - CGFloat(data[index].score / maxScore) * height
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                            .position(x: x, y: y)
                            .opacity(showingPoints ? 1 : 0)
                            .animation(.easeInOut(duration: 1.0).delay(Double(index) * 0.1), value: showingPoints)
                            .overlay(
                                Text(String(format: "%.1f", data[index].score))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                    .offset(y: -20)
                                    .opacity(showingPoints ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1 + 0.5), value: showingPoints)
                            )
                    }
                }
            }
            .frame(height: 200)
            .padding(.top, 20)
            
            // X-axis labels
            HStack {
                ForEach(0..<data.count, id: \.self) { index in
                    Text(data[index].date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingPoints = true
            }
        }
    }
    
    var trendText: String {
        switch trend {
        case .improving:
            return "Yükseliyor"
        case .declining:
            return "Düşüyor"
        case .stable:
            return "Sabit"
        }
    }
}

struct SubjectRecommendationsView: View {
    let subject: String
    
    var recommendations: [String] {
        switch subject {
        case "Türkçe":
            return ["Paragraf soruları için günlük okuma alışkanlığı geliştir", "Dil bilgisi kurallarını tekrar et", "Sözcük anlamları için kelime kartları hazırla"]
        case "Matematik":
            return ["Temel kavramları gözden geçir", "Bol soru çözerek pratik yap", "Formülleri düzenli tekrar et"]
        case "Fizik":
            return ["Formülleri ezberlemek yerine mantığını anla", "Günlük hayattan örneklerle konuları pekiştir", "Temel kavramları tekrar et"]
        case "Kimya":
            return ["Periyodik tabloyu iyi öğren", "Kimyasal tepkimeleri görselleştir", "Temel kavramları düzenli tekrar et"]
        case "Biyoloji":
            return ["Görsel materyallerle çalış", "Konuları birbiriyle ilişkilendir", "Temel kavramları düzenli tekrar et"]
        case "Tarih":
            return ["Kronolojik sıralamaya dikkat et", "Kavram haritaları oluştur", "Önemli olayları tarih şeridi üzerinde işaretle"]
        case "Coğrafya":
            return ["Harita üzerinde çalış", "Kavramları günlük hayatla ilişkilendir", "Görsel materyallerle destekle"]
        case "Edebiyat":
            return ["Edebi akımları ve özelliklerini öğren", "Önemli yazarları ve eserlerini listele", "Örnek metinler üzerinde çalış"]
        default:
            return ["Düzenli çalışma programı oluştur", "Eksik konuları belirle ve önceliklendir", "Bol soru çözerek pratik yap"]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text("\(subject) İçin Öneriler")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            ForEach(recommendations, id: \.self) { recommendation in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 2)
                    
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
