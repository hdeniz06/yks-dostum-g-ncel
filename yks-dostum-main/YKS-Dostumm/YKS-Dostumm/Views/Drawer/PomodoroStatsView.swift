import SwiftUI

struct PomodoroStatsView: View {
    @ObservedObject var viewModel: TimersViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Toplam çalışma istatistikleri
                    statsCard(
                        title: "Toplam Çalışma İstatistikleri",
                        items: [
                            StatItem(
                                title: "Toplam Çalışma Süresi",
                                value: viewModel.formatTimeRemaining(viewModel.totalWorkTime),
                                icon: "clock.fill",
                                color: .blue
                            ),
                            StatItem(
                                title: "Tamamlanan Seans",
                                value: "\(viewModel.totalCompletedSessions)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        ]
                    )
                    
                    // Bugünkü istatistikler (örnek)
                    statsCard(
                        title: "Bugünkü İstatistikler",
                        items: [
                            StatItem(
                                title: "Çalışma Süresi",
                                value: viewModel.formatTimeRemaining(viewModel.totalWorkTime),
                                icon: "clock.fill",
                                color: .orange
                            ),
                            StatItem(
                                title: "Tamamlanan Pomodoro",
                                value: "\(viewModel.completedSessions)",
                                icon: "number.circle.fill",
                                color: .purple
                            )
                        ]
                    )
                    
                    // Bu hafta istatistikleri (örnek)
                    statsCard(
                        title: "Bu Hafta",
                        items: [
                            StatItem(
                                title: "Toplam Çalışma",
                                value: viewModel.formatTimeRemaining(viewModel.totalWorkTime),
                                icon: "clock.fill",
                                color: .blue
                            ),
                            StatItem(
                                title: "Günlük Ortalama",
                                value: viewModel.formatTimeRemaining(viewModel.totalWorkTime / 7),
                                icon: "chart.bar.fill",
                                color: .pink
                            )
                        ]
                    )
                    
                    // İstatistikleri sıfırlama butonu
                    Button(action: {
                        viewModel.resetStats()
                    }) {
                        Text("İstatistikleri Sıfırla")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Pomodoro İstatistikleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func statsCard(title: String, items: [StatItem]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(items) { item in
                    HStack(spacing: 15) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .foregroundColor(item.color)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(item.value)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}
