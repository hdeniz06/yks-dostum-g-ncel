import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: AchievementsViewModel
    @State private var selectedCategory: AchievementCategory = .general
    
    var body: some View {
        VStack(spacing: 0) {
            // İlerleme Göstergesi
            HStack {
                Text("Tamamlanan:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.getCompletedAchievementsCount())/\(viewModel.getTotalAchievementsCount())")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // İlerleme Çubuğu
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.1)
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * Double(viewModel.getCompletedAchievementsCount()) / Double(max(1, viewModel.getTotalAchievementsCount())), height: 8)
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                .frame(width: 100, height: 8)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 15)
            
            // Kategori Seçici - Yatay Kaydırılabilir Butonlar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AchievementCategory.allCases) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.getCategoryIcon(category))
                                    .font(.system(size: 14))
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                
                                Text(category.rawValue)
                                    .font(.system(size: 13))
                                    .lineLimit(1)
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.blue : Color(UIColor.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            // Seçilen Kategorideki Rozetler
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.getAchievementsByCategory(category: selectedCategory)) { achievement in
                        AchievementItemView(achievement: achievement)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                // İkon
                ZStack {
                    Circle()
                        .fill(achievement.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(achievement.isCompleted ? .green : .gray)
                }
                
                // Başlık ve Açıklama
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isCompleted ? .primary : .secondary)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // İlerleme Metni
                Text(achievement.progressText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // İlerleme Çubuğu
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.1)
                        .foregroundColor(.gray)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * achievement.progress, height: 8)
                        .foregroundColor(achievement.isCompleted ? .green : .blue)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    AchievementsView(viewModel: AchievementsViewModel())
}
