import SwiftUI

struct SidebarAchievementsView: View {
    @ObservedObject var viewModel: AchievementsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text("Rozetlerim")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.getCompletedAchievementsCount())/\(viewModel.getTotalAchievementsCount())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 5)
            
            // Featured Achievements (show 3 most recent or in-progress)
            ForEach(getFeaturedAchievements()) { achievement in
                SidebarAchievementItemView(achievement: achievement)
            }
            
            // View All Button
            Button(action: {
                // This will be handled in the DrawerView
            }) {
                Text("Tüm Rozetleri Gör")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.vertical, 5)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal)
        )
    }
    
    // Get 3 featured achievements (prioritize in-progress ones)
    private func getFeaturedAchievements() -> [Achievement] {
        let inProgress = viewModel.achievements
            .filter { !$0.isCompleted && $0.currentCount > 0 }
            .sorted { $0.progress > $1.progress }
        
        let completed = viewModel.achievements
            .filter { $0.isCompleted }
            .sorted { $0.currentCount > $1.currentCount }
        
        let notStarted = viewModel.achievements
            .filter { $0.currentCount == 0 }
        
        return Array((inProgress + completed + notStarted).prefix(3))
    }
}

struct SidebarAchievementItemView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(achievement.isCompleted ? .green : .gray)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline)
                    .foregroundColor(achievement.isCompleted ? .primary : .secondary)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 4)
                            .opacity(0.1)
                            .foregroundColor(.gray)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * achievement.progress, height: 4)
                            .foregroundColor(achievement.isCompleted ? .green : .blue)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Progress Text
            Text(achievement.progressText)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemBackground))
        )
    }
}

#Preview {
    SidebarAchievementsView(viewModel: AchievementsViewModel())
}
