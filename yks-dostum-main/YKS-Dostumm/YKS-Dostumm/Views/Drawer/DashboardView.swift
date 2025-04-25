import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var newTodoText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Message
                Text(viewModel.welcomeMessage)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Countdown to YKS
                if let examDate = viewModel.nextExamDate {
                    ExamCountdownView(examDate: examDate)
                }
                
                // Study Progress
                StudyProgressView(stats: viewModel.studyStats)
                
                // Todo List
                TodoListView(
                    todoItems: viewModel.todoItems,
                    newTodoText: $newTodoText,
                    onToggle: viewModel.toggleTodoItem,
                    onAdd: {
                        if !newTodoText.isEmpty {
                            viewModel.addTodoItem(title: newTodoText)
                            newTodoText = ""
                        }
                    }
                )
            }
            .padding(.vertical)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 80, height: 80)
                    )
            }
        }
    }
}

struct ExamCountdownView: View {
    let examDate: Date
    @State private var daysRemaining: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YKS'ye Kalan Süre")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .center) {
                    Text("\(daysRemaining)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    Text("GÜN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("YKS Tarihi:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(examDate, style: .date)
                        .font(.headline)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
        .onAppear {
            updateDaysRemaining()
        }
    }
    
    private func updateDaysRemaining() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        daysRemaining = components.day ?? 0
    }
}

struct StudyProgressView: View {
    let stats: DashboardStudyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Çalışma İstatistikleri")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 15) {
                // Daily Study Hours
                StatItemView(
                    value: String(format: "%.1f", stats.dailyStudyHours),
                    label: "Bugün",
                    icon: "clock.fill",
                    color: .green
                )
                
                // Weekly Study Hours
                StatItemView(
                    value: String(format: "%.1f", stats.weeklyStudyHours),
                    label: "Bu Hafta",
                    icon: "calendar",
                    color: .blue
                )
                
                // Topic Completion
                StatItemView(
                    value: String(format: "%.0f%%", stats.topicCompletionPercentage),
                    label: "Tamamlanan",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 5) {
                Text("Konu İlerlemesi: \(stats.completedTopics)/\(stats.totalTopics)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.2)
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(stats.topicCompletionPercentage) * geometry.size.width / 100, geometry.size.width), height: 8)
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

struct StatItemView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

struct TodoListView: View {
    let todoItems: [TodoItem]
    @Binding var newTodoText: String
    let onToggle: (UUID) -> Void
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Yapılacaklar")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(todoItems) { item in
                    HStack {
                        Button(action: {
                            onToggle(item.id)
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                                .font(.system(size: 20))
                        }
                        
                        Text(item.title)
                            .font(.subheadline)
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(Color(UIColor.systemBackground))
                    
                    if todoItems.last?.id != item.id {
                        Divider()
                            .padding(.leading, 45)
                    }
                }
                
                // Add new todo
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    
                    TextField("Yeni görev ekle", text: $newTodoText)
                        .font(.subheadline)
                    
                    Button(action: onAdd) {
                        Text("Ekle")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .disabled(newTodoText.isEmpty)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel())
}
