import SwiftUI

struct YKSCountdownView: View {
    let examDate: Date
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 15) {
            Text("YKS Sınavına Kalan Süre")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 15) {
                timeBlock(value: days, label: "Gün")
                timeBlock(value: hours, label: "Saat")
                timeBlock(value: minutes, label: "Dakika")
                timeBlock(value: seconds, label: "Saniye")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .onAppear {
            updateTimeRemaining()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTimeRemaining()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, examDate.timeIntervalSince(Date()))
    }
    
    private func timeBlock(value: Int, label: String) -> some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .frame(minWidth: 40)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var days: Int {
        Int(timeRemaining / (24 * 3600))
    }
    
    private var hours: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 24 * 3600)) / 3600)
    }
    
    private var minutes: Int {
        Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    private var seconds: Int {
        Int(timeRemaining.truncatingRemainder(dividingBy: 60))
    }
}
