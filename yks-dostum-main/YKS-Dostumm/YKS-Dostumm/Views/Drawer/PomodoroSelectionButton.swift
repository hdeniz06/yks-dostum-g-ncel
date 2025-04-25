import SwiftUI

struct PomodoroSelectionButton: View {
    let timer: PomodoroTimer
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 5) {
                HStack(spacing: 5) {
                    Image(systemName: "timer")
                        .font(.caption)
                    Text("\(Int(timer.workDuration / 60)):\(Int(timer.breakDuration / 60))")
                        .font(.caption2)
                }
                .foregroundColor(isSelected ? .white : .primary)
                
                Text(timer.name)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
