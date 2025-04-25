import SwiftUI

struct AddTaskView: View {
    // Core properties
    let date: Date
    let onAdd: (StudyTask) -> Void
    let onCancel: () -> Void
    let editingTask: StudyTask?
    
    // Task properties
    @State private var subject: String
    @State private var description: String
    @State private var startTime: Date
    @State private var duration: Double
    @State private var priority: TaskPriority
    @State private var category: StudyCategory
    @State private var notes: String
    
    // View state
    @State private var showSubjectPicker = false
    @State private var showingDatePicker = false
    @State private var showingDurationPicker = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = StudyPlanViewModel()
    
    // MARK: - Initialization
    
    init(
        date: Date,
        onAdd: @escaping (StudyTask) -> Void,
        onCancel: @escaping () -> Void,
        editingTask: StudyTask? = nil
    ) {
        self.date = date
        self.onAdd = onAdd
        self.onCancel = onCancel
        self.editingTask = editingTask
        
        // Set default start time to current hour or 9 AM if initializing a new task
        let calendar = Calendar.current
        
        if let task = editingTask {
            // Initialize with existing task values
            _subject = State(initialValue: task.subject)
            _description = State(initialValue: task.description)
            _startTime = State(initialValue: task.startTime)
            _duration = State(initialValue: task.duration)
            _priority = State(initialValue: task.priority)
            _category = State(initialValue: task.category)
            _notes = State(initialValue: task.notes ?? "")
        } else {
            // Default values for new task
            let hour = max(9, calendar.component(.hour, from: Date()))
            let defaultStartTime = calendar.date(
                bySettingHour: hour,
                minute: 0,
                second: 0,
                of: date
            ) ?? date
            
            _subject = State(initialValue: "")
            _description = State(initialValue: "")
            _startTime = State(initialValue: defaultStartTime)
            _duration = State(initialValue: 1.0)
            _priority = State(initialValue: .medium)
            _category = State(initialValue: .general)
            _notes = State(initialValue: "")
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Basic Information Section
                Section(header: Text("Görev Bilgileri").font(.headline)) {
                    // Subject picker
                    HStack {
                        Text("Ders")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(subject.isEmpty ? "Ders Seç" : subject) {
                            showSubjectPicker = true
                        }
                        .foregroundColor(subject.isEmpty ? .blue : .primary)
                    }
                    .sheet(isPresented: $showSubjectPicker) {
                        SubjectPickerView(
                            subjects: viewModel.availableSubjects,
                            selectedSubject: $subject,
                            isPresented: $showSubjectPicker
                        )
                    }
                    
                    // Description field
                    TextField("Açıklama", text: $description)
                        .onChange(of: subject) { oldValue, newValue in
                            // Auto-suggest a description if one isn't entered
                            if description.isEmpty && !newValue.isEmpty {
                                description = "\(newValue) \(category.rawValue)"
                            }
                        }
                        .onChange(of: category) { oldValue, newValue in
                            // Update description when category changes
                            if !subject.isEmpty {
                                description = "\(subject) \(newValue.rawValue)"
                            }
                        }
                }
                
                // MARK: - Time Section
                Section(header: Text("Zaman").font(.headline)) {
                    // Start time picker
                    HStack {
                        Text("Başlangıç")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(formatTime(startTime)) {
                            showingDatePicker = true
                        }
                        .foregroundColor(.primary)
                    }
                    .sheet(isPresented: $showingDatePicker) {
                        NavigationView {
                            VStack {
                                DatePicker(
                                    "Başlangıç Saati",
                                    selection: $startTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .padding()
                                
                                Text("Bitiş: \(formatTime(endTime))")
                                    .foregroundColor(.secondary)
                                    .padding(.bottom)
                            }
                            .navigationBarTitle("Başlangıç Saati", displayMode: .inline)
                            .navigationBarItems(
                                trailing: Button("Tamam") {
                                    showingDatePicker = false
                                }
                            )
                        }
                    }
                    
                    // Duration picker
                    HStack {
                        Text("Süre")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("\(String(format: "%.1f", duration)) saat") {
                            showingDurationPicker = true
                        }
                        .foregroundColor(.primary)
                    }
                    .sheet(isPresented: $showingDurationPicker) {
                        NavigationView {
                            VStack {
                                Picker("Süre", selection: $duration) {
                                    ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], id: \.self) { value in
                                        Text("\(String(format: "%.1f", value)) saat")
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 150)
                                
                                Text("Bitiş: \(formatTime(endTime))")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                            .navigationBarTitle("Çalışma Süresi", displayMode: .inline)
                            .navigationBarItems(
                                trailing: Button("Tamam") {
                                    showingDurationPicker = false
                                }
                            )
                        }
                    }
                }
                
                // MARK: - Details Section
                Section(header: Text("Detaylar").font(.headline)) {
                    // Category picker
                    Picker("Kategori", selection: $category) {
                        ForEach(StudyCategory.allCases) { category in
                            Label(
                                category.rawValue,
                                systemImage: category.icon
                            )
                            .tag(category)
                        }
                    }
                    
                    // Priority picker
                    Picker("Öncelik", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            HStack {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    
                    // Notes text editor
                    VStack(alignment: .leading) {
                        Text("Notlar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Çalışma hakkında notlar...")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .background(Color(.systemBackground))
                        }
                    }
                }
            }
            .navigationTitle(editingTask != nil ? "Görevi Düzenle" : "Yeni Görev")
            .navigationBarItems(
                leading: Button("İptal") {
                    onCancel()
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(editingTask != nil ? "Kaydet" : "Ekle") {
                    let task = StudyTask(
                        id: editingTask?.id ?? UUID(),
                        subject: subject,
                        description: description.isEmpty ? "\(subject) Çalışması" : description,
                        startTime: startTime,
                        duration: duration,
                        isCompleted: editingTask?.isCompleted ?? false,
                        priority: priority,
                        notes: notes.isEmpty ? nil : notes,
                        category: category
                    )
                    onAdd(task)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(subject.isEmpty)
                .fontWeight(.semibold)
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: Int(duration * 60), to: startTime) ?? startTime
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Subject picker view
struct SubjectPickerView: View {
    let subjects: [String]
    @Binding var selectedSubject: String
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var filteredSubjects: [String] {
        if searchText.isEmpty {
            return subjects
        } else {
            return subjects.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Ders Ara", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Subject list
                List {
                    ForEach(filteredSubjects, id: \.self) { subject in
                        Button(action: {
                            selectedSubject = subject
                            isPresented = false
                        }) {
                            HStack {
                                Text(subject)
                                Spacer()
                                if selectedSubject == subject {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationBarTitle("Ders Seç", displayMode: .inline)
            .navigationBarItems(
                leading: Button("İptal") {
                    isPresented = false
                },
                trailing: Button("Tamam") {
                    isPresented = false
                }
            )
        }
    }
}

#Preview {
    AddTaskView(
        date: Date(),
        onAdd: { _ in },
        onCancel: { }
    )
}
