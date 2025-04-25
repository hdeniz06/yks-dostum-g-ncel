import SwiftUI

struct AddCountdownView: View {
    @ObservedObject var viewModel: TimersViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var targetDate = Date().addingTimeInterval(86400) // Varsayılan olarak 1 gün sonrası
    @State private var selectedColor: Color = .blue
    
    private let colorOptions: [Color] = [.blue, .green, .red, .orange, .purple, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Geri Sayım Adı")) {
                    TextField("Örn: Deneme Sınavı", text: $name)
                }
                
                Section(header: Text("Hedef Tarih")) {
                    DatePicker("Tarih ve Saat", selection: $targetDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section(header: Text("Renk")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                        ForEach(colorOptions, id: \.self) { color in
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                
                                if color == selectedColor {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: saveCountdown) {
                        Text("Kaydet")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Yeni Geri Sayım")
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
    
    private func saveCountdown() {
        let newTimer = CountdownTimer(
            name: name.isEmpty ? "Geri Sayım \(viewModel.countdownTimers.count + 1)" : name,
            targetDate: targetDate,
            color: selectedColor
        )
        
        viewModel.addCountdownTimer(newTimer)
        presentationMode.wrappedValue.dismiss()
    }
}
