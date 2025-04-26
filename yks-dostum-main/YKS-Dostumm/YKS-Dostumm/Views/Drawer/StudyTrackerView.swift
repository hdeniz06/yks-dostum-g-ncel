import SwiftUI

struct StudyTrackerView: View {
    @StateObject private var viewModel = StudyTrackerViewModel()
    @State private var selectedTopic: String = "Matematik"
    @State private var targetMinutes: Int = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Çalışma Takibi")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            // Konu seçimi
            Picker("Konu", selection: $selectedTopic) {
                ForEach(viewModel.availableTopics(), id: \.self) { topic in
                    Text(topic)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Hedef süre seçimi
            HStack {
                Text("Hedef Süre: ")
                Stepper(value: $targetMinutes, in: 10...180, step: 10) {
                    Text("\(targetMinutes) dk")
                }
            }
            
            // Sayaç ve başlat/durdur
            HStack(spacing: 30) {
                Text(timeString(from: viewModel.elapsedTime))
                    .font(.system(size: 48, design: .monospaced))
                    .frame(width: 160)
                
                if viewModel.timerRunning {
                    Button("Durdur") {
                        viewModel.pauseSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button("Başlat") {
                        viewModel.startSession(topic: selectedTopic, targetMinutes: targetMinutes)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            
            // İlerleme çubuğu
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .padding(.vertical)
            
            // Oturum geçmişi
            Text("Oturumlar")
                .font(.headline)
            List(viewModel.sessions) { session in
                HStack {
                    Text(session.topic)
                    Spacer()
                    Text("\(Int(session.completedDuration / 60)) dk")
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 120)
            
            // Rozet rafı
            Text("Rozetler")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.badges) { badge in
                        VStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text(badge.name)
                                .font(.caption)
                            Text(badge.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.yellow.opacity(0.2)))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showBadge) {
            Alert(title: Text("Tebrikler!"), message: Text(viewModel.earnedBadge?.name ?? "Rozet Kazandın!"), dismissButton: .default(Text("Tamam")))
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
