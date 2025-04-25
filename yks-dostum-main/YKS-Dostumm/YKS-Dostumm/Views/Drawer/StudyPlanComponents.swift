import SwiftUI

// Task list item view for list mode
struct TaskListItemView: View {
    let task: StudyTask
    let onTap: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(alignment: .center, spacing: 2) {
                Text(formatTime(task.startTime))
                    .font(.system(size: 16, weight: .semibold))
                
                Text(formatTime(task.endTime))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(width: 55)
            
            // Category indicator
            Image(systemName: task.category.icon)
                .foregroundColor(Color(task.priority.color))
                .frame(width: 30)
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.subject)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 10) {
                    Label(
                        String(format: "%.1f saat", task.duration),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(task.priority.color).opacity(0.2))
                        .foregroundColor(Color(task.priority.color))
                        .cornerRadius(4)
                }
            }
            .flex()
            
            // Completion button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Enhanced day plan view for calendar mode
struct DayPlanView: View {
    let studyDay: StudyDay
    let onToggleTask: (Int) -> Void
    let onEditTask: (Int) -> Void
    let onDeleteTask: (Int) -> Void
    let onAddTask: () -> Void
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func formatDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Day header
            HStack {
                Text(formatDate(studyDay.date))
                    .font(.headline)
                
                Spacer()
                
                // Add today indicator if applicable
                if Calendar.current.isDateInToday(studyDay.date) {
                    Text("Bugün")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                // Add total hours indicator
                Text(String(format: "Toplam: %.1f saat", studyDay.totalHours))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
            
            // Progress indicator
            if !studyDay.tasks.isEmpty {
                ProgressView(
                    value: studyDay.completionPercentage,
                    total: 100
                )
                .progressViewStyle(LinearProgressViewStyle(tint: studyDay.completionPercentage == 100 ? .green : .blue))
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)
                
                Text("\(studyDay.completedTasksCount)/\(studyDay.tasks.count) tamamlandı")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Tasks
            if studyDay.tasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                        
                        Text("Bu gün için görev yok")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: onAddTask) {
                            Text("Görev Ekle")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(studyDay.tasks.indices, id: \.self) { index in
                    TaskItemView(
                        task: studyDay.tasks[index],
                        onToggle: { onToggleTask(index) },
                        onEdit: { onEditTask(index) },
                        onDelete: { onDeleteTask(index) }
                    )
                    
                    if index < studyDay.tasks.count - 1 {
                        Divider()
                    }
                }
                
                // Add task button
                HStack {
                    Spacer()
                    Button(action: onAddTask) {
                        Label("Yeni Görev Ekle", systemImage: "plus")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Individual task item view for calendar day view
struct TaskItemView: View {
    let task: StudyTask
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 4) {
                Text(Self.timeFormatter.string(from: task.startTime))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(Self.timeFormatter.string(from: task.endTime))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color(task.priority.color).opacity(0.7))
                    .frame(width: 2, height: 30)
            }
            .frame(width: 50)
            
            // Task details
            VStack(alignment: .leading, spacing: 5) {
                Text(task.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Image(systemName: task.category.icon)
                            .font(.caption)
                        
                        Text(task.subject)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(task.priority.color).opacity(0.1))
                    .foregroundColor(Color(task.priority.color))
                    .cornerRadius(8)
                    
                    Text(String(format: "%.1f saat", task.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .flex()
            
            // Action buttons
            HStack(spacing: 16) {
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                
                // Completion button
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Statistics card view
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Extension to make flexible width views
extension View {
    func flex() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
}
