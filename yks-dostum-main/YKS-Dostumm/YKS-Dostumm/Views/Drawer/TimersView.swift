import SwiftUI

struct TimersView: View {
    @ObservedObject var viewModel: TimersViewModel
    @State private var selectedTab = 0
    @State private var showingAddPomodoro = false
    @State private var showingAddCountdown = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık ve Sekme Seçici
            VStack(spacing: 0) {
                Picker("Timer Tipi", selection: $selectedTab) {
                    Text("Pomodoro").tag(0)
                    Text("Geri Sayım").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            // İçerik
            TabView(selection: $selectedTab) {
                // Pomodoro Sekmesi
                PomodoroTabView(viewModel: viewModel, showingAddPomodoro: $showingAddPomodoro)
                    .tag(0)
                
                // Geri Sayım Sekmesi
                CountdownTabView(viewModel: viewModel, showingAddCountdown: $showingAddCountdown)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Sayaç")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if selectedTab == 0 {
                        showingAddPomodoro = true
                    } else {
                        showingAddCountdown = true
                    }
                }) {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddPomodoro) {
            AddPomodoroView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCountdown) {
            AddCountdownView(viewModel: viewModel)
        }
    }
}

// MARK: - Pomodoro Sekmesi
struct PomodoroTabView: View {
    @ObservedObject var viewModel: TimersViewModel
    @Binding var showingAddPomodoro: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Pomodoro Seçici
            if !viewModel.pomodoroTimers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.pomodoroTimers) { timer in
                            PomodoroSelectionButton(
                                timer: timer,
                                isSelected: viewModel.selectedPomodoroTimer?.id == timer.id,
                                onSelect: {
                                    viewModel.selectPomodoroTimer(timer)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                }
            }
            
            // Ana Pomodoro Görünümü
            PomodoroTimerView(viewModel: viewModel)
            
            // Yeni Pomodoro Ekleme Butonu
            Button(action: {
                self.showingAddPomodoro = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Yeni Pomodoro Ekle")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                        .background(Color.blue.opacity(0.05))
                )
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            
            // Pomodoro Listesi
            if !viewModel.pomodoroTimers.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Pomodoro Zamanlayıcıları")
                        .font(.headline)
                        .padding()
                    
                    List {
                        ForEach(viewModel.pomodoroTimers) { timer in
                            PomodoroListItem(
                                timer: timer, 
                                isSelected: viewModel.selectedPomodoroTimer?.id == timer.id,
                                onSelect: { viewModel.selectPomodoroTimer(timer) },
                                onDelete: { viewModel.deletePomodoroTimer(at: IndexSet([viewModel.pomodoroTimers.firstIndex(where: { $0.id == timer.id }) ?? 0])) }
                            )
                            .padding(.vertical, 5)
                        }
                        .onDelete { indexSet in
                            viewModel.deletePomodoroTimer(at: indexSet)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            // Pomodoro İstatistikleri
            NavigationLink(destination: PomodoroStatsView(viewModel: viewModel)) {
                Text("Pomodoro İstatistikleri")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                            .background(Color.blue.opacity(0.05))
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Geri Sayım Sekmesi
struct CountdownTabView: View {
    @ObservedObject var viewModel: TimersViewModel
    @Binding var showingAddCountdown: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // YKS Geri Sayımı
            YKSCountdownView(examDate: viewModel.yksExamDate)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
            // Yeni Geri Sayım Ekleme Butonu
            Button(action: {
                self.showingAddCountdown = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Yeni Geri Sayım Ekle")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                        .background(Color.blue.opacity(0.05))
                )
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            
            // Geri Sayım Listesi
            if viewModel.countdownTimers.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Henüz geri sayım eklenmemiş")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Yeni bir geri sayım eklemek için sağ üstteki + butonuna tıklayın")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.countdownTimers) { timer in
                        CountdownListItem(
                            timer: timer,
                            onDelete: { viewModel.deleteCountdownTimer(at: IndexSet([viewModel.countdownTimers.firstIndex(where: { $0.id == timer.id }) ?? 0])) }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Pomodoro Timer Görünümü
struct PomodoroTimerView: View {
    @ObservedObject var viewModel: TimersViewModel
    @State private var showingStats = false
    
    var phaseColor: Color {
        switch viewModel.currentPhase {
        case .work:
            return .blue
        case .break:
            return .green
        case .longBreak:
            return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.pomodoroTimers.isEmpty {
                emptyStateView
            } else {
                timerSelectionView
                
                if viewModel.currentPomodoroState != .stopped {
                    activeTimerView()
                } else {
                    startButtonView
                }
                
                // Çalışma istatistikleri butonu
                Button(action: {
                    showingStats.toggle()
                }) {
                    HStack {
                        Image(systemName: "chart.bar")
                        Text("Çalışma İstatistikleri")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.top, 10)
                .sheet(isPresented: $showingStats) {
                    PomodoroStatsView(viewModel: viewModel)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.loadTimers()
        }
    }
    
    func activeTimerView() -> some View {
        VStack(spacing: 15) {
            // Faz Bilgisi
            Text(viewModel.currentPhaseText)
                .font(.headline)
                .foregroundColor(phaseColor)
            
            // Seans ve faz göstergesi
            if let selectedTimer = viewModel.selectedPomodoroTimer {
                HStack(spacing: 20) {
                    ForEach(0..<selectedTimer.sessionsBeforeLongBreak, id: \.self) { session in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(session < viewModel.completedSessions ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            Text("\(session + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            
            // Zamanlayıcı
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.3)
                    .foregroundColor(phaseColor)
                
                Circle()
                    .trim(from: 0.0, to: viewModel.progressValue)
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(phaseColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: viewModel.progressValue)
                
                VStack(spacing: 5) {
                    Text(viewModel.formattedTimeRemaining)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    
                    if viewModel.currentPomodoroState == .paused {
                        Text("Duraklatıldı")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 250, height: 250)
            
            // Kontrol Butonları
            HStack(spacing: 30) {
                Button(action: {
                    viewModel.resetPomodoro()
                }) {
                    VStack {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.red)
                        Text("Durdur")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: {
                    if viewModel.currentPomodoroState == .paused {
                        viewModel.resumePomodoro()
                    } else {
                        viewModel.pausePomodoro()
                    }
                }) {
                    VStack {
                        Image(systemName: viewModel.currentPomodoroState == .paused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                        Text(viewModel.currentPomodoroState == .paused ? "Devam Et" : "Duraklat")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: {
                    viewModel.skipToNextPhase()
                }) {
                    VStack {
                        Image(systemName: "forward.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)
                        Text("Atla")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Toplam çalışma süresi
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Toplam Çalışma")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formatTimeRemaining(viewModel.totalWorkTime))
                        .font(.headline)
                }
                
                Spacer()
                
                if let selectedTimer = viewModel.selectedPomodoroTimer {
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Seans")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.completedSessions)/\(selectedTimer.sessionsBeforeLongBreak)")
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Henüz pomodoro zamanlayıcısı eklenmemiş")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Yeni bir pomodoro zamanlayıcısı eklemek için + butonuna tıklayın")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    var timerSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.pomodoroTimers) { timer in
                    PomodoroSelectionButton(
                        timer: timer,
                        isSelected: viewModel.selectedPomodoroTimer?.id == timer.id,
                        onSelect: {
                            viewModel.selectPomodoroTimer(timer)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    var startButtonView: some View {
        VStack(spacing: 20) {
            if let selectedTimer = viewModel.selectedPomodoroTimer {
                VStack(spacing: 10) {
                    Text(selectedTimer.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Pomodoro ayarları kartı
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    VStack(spacing: 0) {
                                        Text("\(Int(selectedTimer.workDuration / 60))")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("dk")
                                            .font(.caption2)
                                    }
                                }
                                
                                Text("Çalışma")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    VStack(spacing: 0) {
                                        Text("\(Int(selectedTimer.breakDuration / 60))")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("dk")
                                            .font(.caption2)
                                    }
                                }
                                
                                Text("Kısa Mola")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    VStack(spacing: 0) {
                                        Text("\(Int(selectedTimer.longBreakDuration / 60))")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("dk")
                                            .font(.caption2)
                                    }
                                }
                                
                                Text("Uzun Mola")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    VStack(spacing: 0) {
                                        Text("\(selectedTimer.sessionsBeforeLongBreak)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("seans")
                                            .font(.caption2)
                                    }
                                }
                                
                                Text("Seans")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Çalışma düzeni gösterimi
                        HStack(spacing: 5) {
                            ForEach(0..<min(selectedTimer.sessionsBeforeLongBreak, 8), id: \.self) { session in
                                HStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.blue)
                                        .frame(width: 15, height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.green)
                                        .frame(width: 8, height: 10)
                                    
                                    if session == selectedTimer.sessionsBeforeLongBreak - 1 {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.purple)
                                            .frame(width: 12, height: 10)
                                    }
                                }
                            }
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                
                // Başlat butonu
                Button(action: {
                    viewModel.startPomodoro()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Başlat")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), 
                                       startPoint: .leading, 
                                       endPoint: .trailing)
                    )
                    .cornerRadius(25)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.top, 10)
            }
        }
    }
    
    //    var phaseColor: Color {
    //        switch viewModel.currentPhase {
    //        case .work:
    //            return .blue
    //        case .break:
    //            return .green
    //        case .longBreak:
    //            return .purple
    //        }
    //    }
    //}
    
    // MARK: - Pomodoro İstatistikleri Görünümü
    struct PomodoroStatsView: View {
        @ObservedObject var viewModel: TimersViewModel
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Toplam Çalışma Süresi
                        VStack(spacing: 5) {
                            Text("Toplam Çalışma Süresi")
                                .font(.headline)
                            
                            Text(viewModel.formatTimeRemaining(viewModel.totalWorkTime))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Tamamlanan Seanslar
                        VStack(spacing: 5) {
                            Text("Tamamlanan Seanslar")
                                .font(.headline)
                            
                            Text("\(viewModel.totalCompletedSessions)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Günlük Çalışma Grafiği
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Günlük Çalışma")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Basit çalışma grafiği (son 7 gün)
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(0..<7, id: \.self) { day in
                                    let height = min(150, max(30, Double(day * 20 + 30)))
                                    
                                    VStack {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.7))
                                            .frame(width: 30, height: height)
                                        
                                        Text(weekdayName(for: day))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(15)
                        }
                        
                        // Verimlilik İpuçları
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Verimlilik İpuçları")
                                .font(.headline)
                            
                            ForEach(productivityTips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .padding(.top, 2)
                                    
                                    Text(tip)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding()
                }
                .navigationTitle("Çalışma İstatistikleri")
                .navigationBarItems(trailing: Button("Kapat") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        
        // Haftanın günlerini Türkçe olarak döndürür
        private func weekdayName(for dayOffset: Int) -> String {
            let days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
            let today = Calendar.current.component(.weekday, from: Date())
            let index = (today - 2 + dayOffset) % 7 // Pazartesi 2'den başlar
            return days[index >= 0 ? index : index + 7]
        }
        
        // Verimlilik ipuçları
        private let productivityTips = [
            "Çalışma alanınızı dikkat dağıtıcı unsurlardan arındırın.",
            "Her çalışma seansı öncesinde hedeflerinizi belirleyin.",
            "Uzun molalarda kısa bir yürüyüş yapın.",
            "Çalışma sırasında telefonunuzu sessiz moda alın.",
            "Günde en az 2 pomodoro seansı tamamlamayı hedefleyin."
        ]
    }
    
    
    
    // MARK: - YKS Geri Sayım Görünümü
    struct YKSCountdownView: View {
        let examDate: Date
        @State private var currentDate = Date()
        
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        var body: some View {
            VStack(spacing: 15) {
                Text("YKS Sınavına Kalan Süre")
                    .font(.headline)
                
                HStack(spacing: 15) {
                    CountdownBlock(value: daysRemaining, unit: "Gün")
                    CountdownBlock(value: hoursRemaining, unit: "Saat")
                    CountdownBlock(value: minutesRemaining, unit: "Dakika")
                    CountdownBlock(value: secondsRemaining, unit: "Saniye")
                }
                
                // Sınav tarihi
                Text(formatExamDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
            .onReceive(timer) { _ in
                self.currentDate = Date()
            }
        }
        
        private func formatExamDate() -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: examDate)
        }
        
        private var timeRemaining: TimeInterval {
            return max(0, examDate.timeIntervalSince(currentDate))
        }
        
        private var daysRemaining: Int {
            return Int(timeRemaining) / 86400
        }
        
        private var hoursRemaining: Int {
            return (Int(timeRemaining) % 86400) / 3600
        }
        
        private var minutesRemaining: Int {
            return (Int(timeRemaining) % 3600) / 60
        }
        
        private var secondsRemaining: Int {
            return Int(timeRemaining) % 60
        }
    }
    
    // MARK: - Yardımcı Görünümler
    struct CountdownBlock: View {
        let value: Int
        let unit: String
        
        var body: some View {
            VStack {
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .frame(minWidth: 40)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(minWidth: 60)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
            )
        }
    }
    
    struct PomodoroSelectionButton: View {
        let timer: PomodoroTimer
        let isSelected: Bool
        let onSelect: () -> Void
        
        var body: some View {
            Button(action: onSelect) {
                VStack(spacing: 5) {
                    Text(timer.name)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text("\(Int(timer.workDuration / 60)) dk")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue : Color(UIColor.tertiarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    struct PomodoroListItem: View {
        let timer: PomodoroTimer
        let isSelected: Bool
        let onSelect: () -> Void
        let onDelete: () -> Void
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .blue : .primary)
                    
                    HStack(spacing: 15) {
                        Label("\(Int(timer.workDuration / 60)) dk çalışma", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(Int(timer.breakDuration / 60)) dk mola", systemImage: "cup.and.saucer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            )
        }
    }
    
    struct CountdownListItem: View {
        let timer: CountdownTimer
        let onDelete: () -> Void
        
        var timeRemaining: TimeInterval {
            return max(0, timer.targetDate.timeIntervalSince(Date()))
        }
        
        var color: Color {
            return timer.color
        }
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(timer.name)
                        .font(.headline)
                        .foregroundColor(color)
                    
                    Text(formatTimeRemaining())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
            )
        }
        
        private func formatTimeRemaining() -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .short
            
            let result = formatter.string(from: timeRemaining) ?? "0 dakika"
            
            return result
                .replacingOccurrences(of: "d", with: " gün")
                .replacingOccurrences(of: "h", with: " saat")
                .replacingOccurrences(of: "m", with: " dakika")
        }
        
        private func formatDate() -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: timer.targetDate)
        }
    }
    
    // MARK: - Yeni Pomodoro Ekleme Görünümü
    struct AddPomodoroView: View {
        @ObservedObject var viewModel: TimersViewModel
        @Environment(\.presentationMode) var presentationMode
        
        @State private var name = "Yeni Pomodoro"
        @State private var workMinutes: Double = 25
        @State private var breakMinutes: Double = 5
        @State private var longBreakMinutes: Double = 15
        @State private var sessionsBeforeLongBreak: Double = 4
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Pomodoro Bilgileri")) {
                        TextField("Pomodoro Adı", text: $name)
                    }
                    
                    Section(header: Text("Çalışma Süresi")) {
                        VStack {
                            HStack {
                                Text("\(Int(workMinutes)) dakika")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Slider(value: $workMinutes, in: 5...60, step: 5)
                        }
                    }
                    
                    Section(header: Text("Kısa Mola Süresi")) {
                        VStack {
                            HStack {
                                Text("\(Int(breakMinutes)) dakika")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Slider(value: $breakMinutes, in: 1...30, step: 1)
                        }
                    }
                    
                    Section(header: Text("Uzun Mola Süresi")) {
                        VStack {
                            HStack {
                                Text("\(Int(longBreakMinutes)) dakika")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Slider(value: $longBreakMinutes, in: 5...45, step: 5)
                        }
                    }
                    
                    Section(header: Text("Uzun Mola Öncesi Seans Sayısı")) {
                        VStack {
                            HStack {
                                Text("\(Int(sessionsBeforeLongBreak)) seans")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Slider(value: $sessionsBeforeLongBreak, in: 2...8, step: 1)
                        }
                        
                        HStack(spacing: 10) {
                            ForEach(1...8, id: \.self) { sessions in
                                Text("\(sessions)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Int(sessionsBeforeLongBreak) == sessions ? Color.orange : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(Int(sessionsBeforeLongBreak) == sessions ? .white : .primary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .navigationTitle("Yeni Pomodoro")
                .navigationBarItems(
                    leading: Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Kaydet") {
                        viewModel.addPomodoroTimer(
                            name: name,
                            workDuration: workMinutes * 60,
                            breakDuration: breakMinutes * 60,
                            longBreakDuration: longBreakMinutes * 60,
                            sessionsBeforeLongBreak: Int(sessionsBeforeLongBreak)
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Yeni Geri Sayım Ekleme Görünümü
    struct AddCountdownView: View {
        @ObservedObject var viewModel: TimersViewModel
        @Environment(\.presentationMode) var presentationMode
        
        @State private var name = "Yeni Geri Sayım"
        @State private var targetDate = Date().addingTimeInterval(86400) // 1 gün sonra
        @State private var selectedColor: Color = .blue
        
        let colorOptions: [(Color, String)] = [
            (.blue, "Mavi"),
            (.green, "Yeşil"),
            (.red, "Kırmızı"),
            (.orange, "Turuncu"),
            (.purple, "Mor"),
            (.pink, "Pembe")
        ]
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Geri Sayım Bilgileri")) {
                        TextField("İsim", text: $name)
                        
                        DatePicker("Hedef Tarih", selection: $targetDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section(header: Text("Renk")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(colorOptions, id: \.0) { color, name in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                                .padding(2)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .navigationTitle("Yeni Geri Sayım")
                .navigationBarItems(
                    leading: Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Kaydet") {
                        viewModel.addCountdownTimer(
                            name: name,
                            targetDate: targetDate,
                            color: selectedColor
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    #Preview {
        NavigationView {
            TimersView(viewModel: TimersViewModel())
        }
    }
}
