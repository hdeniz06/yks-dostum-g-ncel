import SwiftUI

struct DrawerView: View {
    @ObservedObject var viewModel: DrawerViewModel
    @StateObject private var achievementsViewModel = AchievementsViewModel()
    @State private var showFullAchievements = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Logo and Title
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("YKS Dostum")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 5)
                
                Text("Sınav Hazırlık Asistanı")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 30)
            
            // Drawer Items
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(DrawerItemType.allCases) { item in
                        DrawerItemView(
                            icon: item.icon,
                            title: item.rawValue,
                            isSelected: viewModel.selectedItem == item,
                            color: item.color
                        )
                        .onTapGesture {
                            viewModel.selectItem(item)
                        }
                    }
                    
                    // Rozetler Menü Öğesi
                    DrawerItemView(
                        icon: "medal.fill",
                        title: "Rozetler",
                        isSelected: false,
                        color: .orange
                    )
                    .overlay(
                        Text("\(achievementsViewModel.getCompletedAchievementsCount())/\(achievementsViewModel.getTotalAchievementsCount())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.trailing, 8),
                        alignment: .trailing
                    )
                    .onTapGesture {
                        showFullAchievements = true
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Version Info
            Text("Versiyon 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .frame(width: 270)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $showFullAchievements) {
            NavigationView {
                AchievementsView(viewModel: achievementsViewModel)
                    .navigationTitle("Rozetlerim")
                    .navigationBarItems(trailing: Button("Kapat") {
                        showFullAchievements = false
                    })
            }
        }
    }
}

struct DrawerItemView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? color : .gray)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? color : .primary)
            
            Spacer()
            
            if isSelected {
                Rectangle()
                    .frame(width: 5, height: 30)
                    .foregroundColor(color)
                    .cornerRadius(3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? color.opacity(0.1) : Color.clear)
        )
    }
}

#Preview {
    DrawerView(viewModel: DrawerViewModel())
}
