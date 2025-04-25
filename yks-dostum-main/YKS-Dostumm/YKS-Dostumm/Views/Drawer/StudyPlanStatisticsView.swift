import SwiftUI

struct StudyPlanStatisticsView: View {
    @ObservedObject var viewModel: StudyPlanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall stats cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Toplam Görev",
                        value: "\(viewModel.studyStats.totalTasks)",
                        icon: "list.bullet",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Tamamlanan",
                        value: "\(viewModel.studyStats.completedTasks)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Toplam Saat",
                        value: String(format: "%.1f", viewModel.studyStats.totalHours),
                        icon: "clock",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Weekly progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("Haftalık İlerleme")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        // Completion percentage
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Tamamlama Oranı")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(viewModel.studyStats.weeklyData.completionPercentage))%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            CircularProgressView(
                                progress: viewModel.studyStats.weeklyData.completionPercentage / 100,
                                color: .blue
                            )
                            .frame(width: 60, height: 60)
                        }
                        
                        // Weekly stats
                        HStack {
                            WeeklyStatItem(
                                title: "Görevler",
                                value: "\(viewModel.studyStats.weeklyData.completedTasks)/\(viewModel.studyStats.weeklyData.totalTasks)",
                                icon: "list.bullet",
                                color: .blue
                            )
                            
                            Divider()
                            
                            WeeklyStatItem(
                                title: "Çalışma Süresi",
                                value: String(format: "%.1f saat", viewModel.studyStats.weeklyData.totalHours),
                                icon: "clock",
                                color: .orange
                            )
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Subject breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Derslere Göre Dağılım")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.studyStats.subjectCompletion.keys.sorted()), id: \.self) { subject in
                            if let stats = viewModel.studyStats.subjectCompletion[subject],
                               let hours = viewModel.studyStats.subjectHours[subject] {
                                SubjectProgressView(
                                    subject: subject,
                                    completedTasks: stats.completed,
                                    totalTasks: stats.total,
                                    hours: hours
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

struct WeeklyStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SubjectProgressView: View {
    let subject: String
    let completedTasks: Int
    let totalTasks: Int
    let hours: Double
    
    private var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(subject)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.1f saat", hours))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                // Completion text
                Text("\(completedTasks)/\(totalTasks)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 45, alignment: .trailing)
            }
        }
    }
}

#Preview {
    StudyPlanStatisticsView(viewModel: StudyPlanViewModel())
}
