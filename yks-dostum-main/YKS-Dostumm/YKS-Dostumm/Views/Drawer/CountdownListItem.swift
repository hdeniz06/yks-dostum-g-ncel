import SwiftUI

struct CountdownListItem: View {
    let timer: CountdownTimer
    let onDelete: () -> Void
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var localTimer: Timer? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(timer.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Label(formatDate(timer.targetDate), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTimeRemaining())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(timer.color)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(8)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(timer.color.opacity(0.1))
        )
        .onAppear {
            updateTimeRemaining()
            localTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTimeRemaining()
            }
        }
        .onDisappear {
            localTimer?.invalidate()
            localTimer = nil
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, timer.targetDate.timeIntervalSince(Date()))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTimeRemaining() -> String {
        if timeRemaining <= 0 {
            return "Tamamlandı!"
        }
        
        let days = Int(timeRemaining / (24 * 3600))
        let hours = Int((timeRemaining.truncatingRemainder(dividingBy: 24 * 3600)) / 3600)
        let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if days > 0 {
            return "\(days) gün \(hours) saat"
        } else if hours > 0 {
            return "\(hours) saat \(minutes) dk"
        } else {
            let seconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))
            return "\(minutes) dk \(seconds) sn"
        }
    }
}
