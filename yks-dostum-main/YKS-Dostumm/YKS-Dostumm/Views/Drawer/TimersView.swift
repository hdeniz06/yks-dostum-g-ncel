import SwiftUI

enum TimerTab {
    case pomodoro, countdown
}

struct TimersView: View {
    @ObservedObject var viewModel: TimersViewModel
    @State private var selectedTab: TimerTab = .pomodoro
    @State private var showingAddCountdown = false
    @State private var showingAddPomodoro = false
    @State private var examDate: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 7, hour: 10, minute: 0)) ?? Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Centered Custom Segmented Control
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                SegmentButton(title: "Pomodoro", isSelected: selectedTab == .pomodoro) {
                    selectedTab = .pomodoro
                }
                Spacer(minLength: 0)
                SegmentButton(title: "Sayaç", isSelected: selectedTab == .countdown) {
                    selectedTab = .countdown
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(UIColor.secondarySystemBackground))
            // Content
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    if selectedTab == .pomodoro {
                        PomodoroTimerView(viewModel: viewModel)
                            .padding()
                    } else if selectedTab == .countdown {
                        VStack(spacing: 28) {
                            // YKS'ye kalan süre
                            YKSCountdownView(examDate: examDate)
                                .padding(.top, 8)
                            // Kullanıcı geri sayım listesi
                            VStack(spacing: 20) {
                                if viewModel.countdownTimers.isEmpty {
                                    VStack(spacing: 15) {
                                        Image(systemName: "hourglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary)
                                        Text("Henüz geri sayım eklenmemiş")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.vertical, 100)
                                } else {
                                    ForEach(viewModel.countdownTimers) { timer in
                                        CountdownListItem(timer: timer) {
                                            if let idx = viewModel.countdownTimers.firstIndex(where: { $0.id == timer.id }) {
                                                viewModel.deleteCountdownTimer(at: IndexSet([idx]))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                // Floating + button for Pomodoro
                if selectedTab == .pomodoro {
                    Button(action: { showingAddPomodoro = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.blue))
                            .shadow(color: Color.blue.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .transition(.scale)
                }
                // Floating + button for Sayaç
                if selectedTab == .countdown {
                    Button(action: { showingAddCountdown = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.blue))
                            .shadow(color: Color.blue.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .transition(.scale)
                }
            }
        }
        .navigationTitle("Sayaç")
        .sheet(isPresented: $showingAddCountdown) {
            AddCountdownView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddPomodoro) {
            AddPomodoroView(viewModel: viewModel)
        }
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CountdownScreen: View {
    @ObservedObject var viewModel: TimersViewModel
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.countdownTimers.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Henüz geri sayım eklenmemiş")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 100)
            } else {
                ForEach(viewModel.countdownTimers) { timer in
                    CountdownCard(timer: timer) {
                        if let idx = viewModel.countdownTimers.firstIndex(where: { $0.id == timer.id }) {
                            viewModel.deleteCountdownTimer(at: IndexSet([idx]))
                        }
                    }
                }
            }
        }
    }
}

struct CountdownCard: View {
    let timer: CountdownTimer
    let onDelete: () -> Void
    var timeRemaining: TimeInterval {
        max(0, timer.targetDate.timeIntervalSince(Date()))
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(timer.name)
                    .font(.headline)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text(formatTimeInterval(timeRemaining))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(timer.color)
                Spacer()
                Text(formatDate(timer.targetDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: 1 - (timeRemaining / timer.targetDate.timeIntervalSince(timer.createdAt)), total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: timer.color))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "00:00:00"
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Pomodoro Timer Görünümü
struct PomodoroTimerView: View {
    @ObservedObject var viewModel: TimersViewModel
    @State private var showingStats = false
    
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
                .foregroundColor(.blue)
            
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
                // Blue-cyan radial gradient background circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.38), Color.cyan.opacity(0.26)]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 110
                        )
                    )
                    .frame(width: 220, height: 220)
                    .shadow(color: Color.blue.opacity(0.13), radius: 16, x: 0, y: 2)

                // Vibrant progress ring (blue-cyan)
                Circle()
                    .trim(from: 0, to: viewModel.progressValue)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan, Color.blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(Angle.degrees(-90))
                    .frame(width: 220, height: 220)
                    .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 0, y: 0)
                    .animation(Animation.easeInOut, value: viewModel.progressValue)

                VStack(spacing: 8) {
                    // Timer text, large, bold, blue-cyan gradient
                    Text(viewModel.formattedTimeRemaining)
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                        .frame(width: 170, alignment: .center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    // Phase label, small, colored
                    let phaseColor: Color = {
                        switch viewModel.currentPhase {
                        case .work: return .blue
                        case .break: return .orange
                        case .longBreak: return .purple
                        }
                    }()
                    if viewModel.currentPomodoroState == .paused {
                        Text("Duraklatıldı")
                            .font(.caption)
                            .foregroundColor(phaseColor)
                            .shadow(color: .black.opacity(0.10), radius: 1, x: 0, y: 1)
                    } else {
                        Text(viewModel.currentPhaseText)
                            .font(.caption)
                            .foregroundColor(phaseColor)
                            .shadow(color: .black.opacity(0.10), radius: 1, x: 0, y: 1)
                    }
                }
            }
            .frame(width: 220, height: 220)

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
                            ForEach(0..<min(selectedTimer.sessionsBeforeLongBreak, 8), id: \.self) { day in
                                let height = min(150, max(30, Double(day * 20 + 30)))
                                
                                VStack {
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: 15, height: height)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.green)
                                        .frame(width: 8, height: 10)
                                    
                                    if day == selectedTimer.sessionsBeforeLongBreak - 1 {
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
}
