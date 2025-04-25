import SwiftUI

struct AddPomodoroView: View {
    @ObservedObject var viewModel: TimersViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var workDuration: Double = 25 // dakika
    @State private var breakDuration: Double = 5 // dakika
    @State private var longBreakDuration: Double = 15 // dakika
    @State private var sessionsBeforeLongBreak: Int = 4
    
    private let minuteOptions = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    private let sessionOptions = [1, 2, 3, 4, 5, 6, 7, 8]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Adı")) {
                    TextField("Örn: Matematik Çalışma", text: $name)
                }
                
                Section(header: Text("Zaman Ayarları (Dakika)")) {
                    HStack {
                        Text("Çalışma Süresi")
                        Spacer()
                        Picker("", selection: $workDuration) {
                            ForEach(minuteOptions, id: \.self) { minute in
                                Text("\(minute) dk").tag(Double(minute))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Kısa Mola Süresi")
                        Spacer()
                        Picker("", selection: $breakDuration) {
                            ForEach(minuteOptions.filter { $0 <= 15 }, id: \.self) { minute in
                                Text("\(minute) dk").tag(Double(minute))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Uzun Mola Süresi")
                        Spacer()
                        Picker("", selection: $longBreakDuration) {
                            ForEach(minuteOptions.filter { $0 <= 30 }, id: \.self) { minute in
                                Text("\(minute) dk").tag(Double(minute))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                }
                
                Section(header: Text("Seans Sayısı")) {
                    HStack {
                        Text("Uzun Mola Öncesi Seans")
                        Spacer()
                        Picker("", selection: $sessionsBeforeLongBreak) {
                            ForEach(sessionOptions, id: \.self) { session in
                                Text("\(session)").tag(session)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                    }
                }
                
                Section {
                    Button(action: savePomodoro) {
                        Text("Kaydet")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Yeni Pomodoro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func savePomodoro() {
        let newTimer = PomodoroTimer(
            name: name.isEmpty ? "Pomodoro \(viewModel.pomodoroTimers.count + 1)" : name,
            workDuration: workDuration * 60, // Saniyeye çevir
            breakDuration: breakDuration * 60, // Saniyeye çevir
            longBreakDuration: longBreakDuration * 60, // Saniyeye çevir
            sessionsBeforeLongBreak: sessionsBeforeLongBreak
        )
        
        viewModel.addPomodoroTimer(newTimer)
        presentationMode.wrappedValue.dismiss()
    }
}
