import SwiftUI

struct WeeklyCalendarView: View {
    let selectedWeek: [Date]
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let onSelectDay: (Date) -> Void
    
    @State private var selectedDayIndex: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    private let weekDays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            // Month and navigation
            HStack {
                Button(action: onPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Spacer()
                
                // Show month and year
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.horizontal)
            
            // Week days
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    let date = selectedWeek[index]
                    let isSelected = index == selectedDayIndex
                    let isToday = calendar.isDateInToday(date)
                    
                    Button(action: {
                        selectedDayIndex = index
                        onSelectDay(date)
                    }) {
                        VStack(spacing: 8) {
                            // Weekday name
                            Text(weekDays[index])
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Day number
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .fill(isToday ? Color.blue : Color.clear)
                                .frame(width: 4, height: 4)
                                .offset(y: 12),
                            alignment: .bottom
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedWeek[0])
    }
}

#Preview {
    WeeklyCalendarView(
        selectedWeek: Array(0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! },
        onPreviousWeek: {},
        onNextWeek: {},
        onSelectDay: { _ in }
    )
}
