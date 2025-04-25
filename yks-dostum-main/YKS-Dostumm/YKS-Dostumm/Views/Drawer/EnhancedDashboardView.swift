import SwiftUI
import Charts

struct EnhancedDashboardView: View {
    @StateObject private var viewModel = EnhancedDashboardViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // MARK: - Motivasyon Kartı
                motivationCard
                
                // MARK: - Günlük Özet
                if let summary = viewModel.dailySummary {
                    dailySummaryCard(summary: summary)
                }
                
                // MARK: - Bugünün Hedefleri
                dailyGoalsSection
                
                // MARK: - Önerilen Çalışma Konuları
                suggestedTopicsSection
                
                // MARK: - Yaklaşan Sınavlar
                upcomingExamsSection
                
                // MARK: - Haftalık İlerleme Grafiği
                if let weeklyData = viewModel.weeklyData {
                    weeklyProgressCard(data: weeklyData)
                }
                
                // MARK: - Başarı Kartları
                achievementsSection
                
                // MARK: - Çalışma Arkadaşları
                buddyActivitiesSection
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .refreshable {
            viewModel.loadData()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Motivasyon Kartı
    private var motivationCard: some View {
        ZStack {
            // Arka plan gradyan
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // İçerik
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                
                Text(viewModel.motivationalQuote)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "quote.closing")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
        .frame(height: 140)
        .padding(.top, 8)
    }
    
    // MARK: - Günlük Özet
    private func dailySummaryCard(summary: DailyStudySummary) -> some View {
        VStack(spacing: 0) {
            // Başlık
            HStack {
                Text("Bugünün Özeti")
                    .font(.headline)
                
                Spacer()
                
                Text(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding([.horizontal, .top])
            
            Divider()
                .padding(.horizontal)
            
            // İçerik
            HStack(spacing: 20) {
                // Çalışma Süresi
                VStack {
                    Text(summary.formattedStudyHours)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("Çalışma Süresi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // İlerlemeler
                VStack {
                    Text("\(summary.completedTasks)/\(summary.totalTasks)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Tamamlanan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // En Çok Çalışılan
                VStack {
                    Text(summary.mostStudiedSubject)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text("En Çok Çalışılan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // İlerleme çubuğu
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Günlük İlerleme")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("%\(Int(summary.completionRate * 100))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Arka plan
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                        
                        // İlerleme
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * summary.completionRate, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Bugünün Hedefleri
    private var dailyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Başlık ve Filtre
            HStack {
                Text("Bugünün Hedefleri")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.todaysGoals.filter { $0.isCompleted }.count)/\(viewModel.todaysGoals.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Hedef listesi
            ForEach(viewModel.todaysGoals) { goal in
                DailyGoalRow(goal: goal) {
                    viewModel.toggleGoalCompletion(goal)
                }
            }
            
            // Yeni hedef ekleme butonu
            Button(action: {
                // Yeni hedef ekleme aksiyon
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Yeni Hedef Ekle")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Önerilen Çalışma Konuları
    private var suggestedTopicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Önerilen Çalışma Konuları")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.suggestedTopics) { suggestion in
                        SuggestedTopicCard(suggestion: suggestion)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Yaklaşan Sınavlar
    private var upcomingExamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yaklaşan Sınavlar")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(viewModel.upcomingExams.prefix(2)) { exam in
                UpcomingExamRow(exam: exam)
            }
            
            if viewModel.upcomingExams.count > 2 {
                Button(action: {
                    // Tüm sınavları gösterme aksiyonu
                }) {
                    Text("Tüm sınavları gör (\(viewModel.upcomingExams.count))")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Haftalık İlerleme Grafiği
    private func weeklyProgressCard(data: WeeklyStudyData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Haftalık İlerlemen")
                .font(.headline)
            
            // Çalışma saatleri grafiği
            VStack(alignment: .leading) {
                Text("Günlük Çalışma Saatleri")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart {
                    ForEach(Array(data.dailyHours.enumerated()), id: \.offset) { index, hours in
                        BarMark(
                            x: .value("Gün", dayOfWeek(for: index)),
                            y: .value("Saat", hours)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
            
            // Ders dağılımı pasta grafiği
            HStack {
                // Burada SwiftUI'da doğrudan pie chart olmadığı için
                // uygulamaya özel bir pasta grafiği eklenebilir
                VStack(alignment: .leading) {
                    Text("Ders Dağılımı")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        // İleride burada bir pie chart olabilir
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Text("Pasta Grafik")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Toplam çalışma saatleri özeti
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Haftalık Toplam:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", data.totalHours)) saat")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Günlük Ortalama:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    Text("\(String(format: "%.1f", data.averageHoursPerDay)) saat")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Başarı Kartları
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Başarıların")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentAchievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Çalışma Arkadaşları
    private var buddyActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Arkadaşlarının Aktiviteleri")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(viewModel.buddyActivities) { activity in
                BuddyActivityRow(activity: activity)
            }
            
            Button(action: {
                // Arkadaş davet etme aksiyonu
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Arkadaşlarını Davet Et")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // Haftanın günlerini al
    private func dayOfWeek(for index: Int) -> String {
        let days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
        return days[index]
    }
}

// MARK: - Yardımcı Görünümler

// Günlük Hedef Satırı
struct DailyGoalRow: View {
    let goal: DailyGoal
    let toggleAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Tamamlama butonu
            Button(action: toggleAction) {
                ZStack {
                    Circle()
                        .stroke(goal.priority.color, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if goal.isCompleted {
                        Circle()
                            .fill(goal.priority.color)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Hedef detayları
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .strikethrough(goal.isCompleted)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
                
                if let subject = goal.subject {
                    Text(subject)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Öncelik göstergesi
            Image(systemName: goal.priority.icon)
                .foregroundColor(goal.priority.color)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// Önerilen Konu Kartı
struct SuggestedTopicCard: View {
    let suggestion: StudySuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Üst bilgi çubuğu
            HStack {
                Text(suggestion.subject)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(suggestion.examType.color)
                    .cornerRadius(12)
                
                Spacer()
                
                Text(suggestion.examType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Konu başlığı
            Text(suggestion.title)
                .font(.headline)
            
            // Öneri nedeni
            HStack {
                Image(systemName: suggestion.reasonForSuggestion.icon)
                    .foregroundColor(suggestion.reasonForSuggestion.color)
                    .font(.caption)
                
                Text(suggestion.reasonForSuggestion.rawValue)
                    .font(.caption)
                    .foregroundColor(suggestion.reasonForSuggestion.color)
            }
            
            Spacer()
            
            // Alt bilgiler
            HStack {
                // Zorluk seviyesi
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { level in
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(level <= suggestion.difficulty ? .orange : .gray.opacity(0.3))
                    }
                }
                
                Spacer()
                
                // Tahmini süre
                Text("\(suggestion.estimatedDuration) dk")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 180, height: 150)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Yaklaşan Sınav Satırı
struct UpcomingExamRow: View {
    let exam: UpcomingExam
    
    var body: some View {
        HStack(spacing: 16) {
            // Gün sayacı
            ZStack {
                Circle()
                    .fill(exam.daysRemaining <= 3 ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 0) {
                    Text("\(exam.daysRemaining)")
                        .font(.headline)
                        .foregroundColor(exam.daysRemaining <= 3 ? .red : .orange)
                    
                    Text("gün")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Sınav detayları
            VStack(alignment: .leading, spacing: 4) {
                Text(exam.title)
                    .font(.headline)
                
                Text(exam.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = exam.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Kayıt durumu/butonu
            if exam.isRegistered {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    // Kayıt aksiyonu
                }) {
                    Text("Kayıt Ol")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Başarı Kartı
struct AchievementCardView: View {
    let achievement: AchievementCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // İkon ve başlık
            HStack {
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.type.color)
                
                Spacer()
                
                Text(achievement.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Başarı bilgileri
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(achievement.type.color)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Tarih
            Text(DateFormatter.localizedString(from: achievement.dateEarned, dateStyle: .short, timeStyle: .none))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(achievement.type.color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.type.color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// Arkadaş Aktivitesi Satırı
struct BuddyActivityRow: View {
    let activity: StudyBuddyActivity
    
    var body: some View {
        HStack(spacing: 12) {
            // Profil resmi
            if let avatarURL = activity.avatarURL {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                // Kullanıcı resmi yoksa baş harflerini göster
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text(String(activity.friendName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            
            // Aktivite detayları
            VStack(alignment: .leading, spacing: 4) {
                // Kullanıcı adı ve aktivite tipi
                HStack {
                    Text(activity.friendName)
                        .font(.headline)
                    
                    Text(activity.activityType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Ders bilgisi
                if let subject = activity.subject {
                    HStack {
                        Image(systemName: activity.activityType.icon)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(subject)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Zaman
            Text(activity.formattedTime)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct EnhancedDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedDashboardView()
    }
}
