import SwiftUI

struct TimerPreset: Identifiable {
    var id = UUID()
    var name: String
    var workMinutes: Int
    var breakMinutes: Int
    var color: Color
}

struct PomodoroView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    @State private var presets: [TimerPreset] = [
        TimerPreset(name: "Standart", workMinutes: 25, breakMinutes: 5, color: .blue),
        TimerPreset(name: "Kısa", workMinutes: 15, breakMinutes: 3, color: .green),
        TimerPreset(name: "Uzun", workMinutes: 50, breakMinutes: 10, color: .purple),
        TimerPreset(name: "Özel", workMinutes: 45, breakMinutes: 15, color: .orange)
    ]
    @State private var selectedPresetIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Timer presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(presets.indices, id: \.self) { index in
                        presetButton(preset: presets[index], isSelected: index == selectedPresetIndex, index: index)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // iOS Clock/Focus style timer
            ZStack {
                // Only a thin, gradient progress ring
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple, Color.blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(Angle.degrees(-90))
                    .frame(width: 220, height: 220)
                    .shadow(color: Color.purple.opacity(0.18), radius: 16, x: 0, y: 0)
                    .animation(Animation.easeInOut, value: viewModel.progress)
                // Timer text with glass effect
                VStack(spacing: 8) {
                    Text(viewModel.timeRemaining.formattedTime())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 2)
                    Text(viewModel.currentPhaseText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.13), radius: 1, x: 0, y: 1)
                }
            }
            .padding(.vertical, 8)
            
            // Session indicators
            HStack(spacing: 15) {
                ForEach(0..<viewModel.sessionsBeforeLongBreak, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.completedSessionsModCycle ? viewModel.phaseColor : Color.gray.opacity(0.3))
                        .frame(width: 14, height: 14)
                }
            }
            // Control buttons
            HStack(spacing: 50) {
                Button(action: { viewModel.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                Button(action: { viewModel.startPause() }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRunning ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .frame(width: 70, height: 70)
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(viewModel.isRunning ? .orange : .green)
                    }
                }
                Button(action: { viewModel.skipPhase() }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]), startPoint: .top, endPoint: .bottom)
        )
    }
    
    private func presetButton(preset: TimerPreset, isSelected: Bool, index: Int) -> some View {
        Button(action: {
            selectedPresetIndex = index
            viewModel.stop()
            viewModel.updateSettings(
                workDuration: TimeInterval(preset.workMinutes * 60),
                shortBreakDuration: TimeInterval(preset.breakMinutes * 60)
            )
        }) {
            VStack(spacing: 4) {
                Text(preset.name)
                    .fontWeight(isSelected ? .bold : .regular)
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("\(preset.workMinutes) dk")
                        .font(.caption)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(isSelected ? preset.color.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? preset.color : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? preset.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}
