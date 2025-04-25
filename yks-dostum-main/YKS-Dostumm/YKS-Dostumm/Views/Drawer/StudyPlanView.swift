import SwiftUI

struct StudyPlanView: View {
    // MARK: - ViewModel
    @StateObject private var viewModel = StudyPlanViewModel()
    
    // MARK: - State
    @State private var showingAddTask = false
    @State private var selectedDay: Date = Date()
    @State private var showDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Mode selector at top
                displayModeSelector
                
                // Main content area
                switch viewModel.displayMode {
                case .calendar: calendarView
                case .list: listView
                case .statistics: StudyPlanStatisticsView(viewModel: viewModel)
                }
            }
            
            // Floating action button
            addTaskButton
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(
                date: selectedDay,
                onAdd: { task in
                    viewModel.addStudyTask(date: selectedDay, task: task)
                    showingAddTask = false
                },
                onCancel: {
                    
                }
            )
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Görevi Sil"),
                message: Text("Bu görev silinecek. Emin misiniz?"),
                primaryButton: .destructive(Text("Sil")) {
                    
                },
                secondaryButton: .cancel() {
                    
                }
            )
        }
    }
    
    // MARK: - View Components
    
    private var displayModeSelector: some View {
        Picker("Görünüm Modu", selection: $viewModel.displayMode) {
            ForEach(StudyPlanViewModel.DisplayMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var addTaskButton: some View {
        Button(action: {
            showingAddTask = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.blue)
                .background(Circle().fill(Color.white).shadow(radius: 3))
        }
        .padding(.bottom, 16)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Yükleniyor...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
            )
            .shadow(radius: 10)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Bu haftaya ait görev bulunamadı")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: {
                showingAddTask = true
            }) {
                Text("Görev Ekle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding(30)
    }
    
    // MARK: - Calendar View
    
    private var calendarView: some View {
        VStack(spacing: 0) {
            WeeklyCalendarView(
                selectedWeek: viewModel.selectedWeek,
                onPreviousWeek: viewModel.moveToPreviousWeek,
                onNextWeek: viewModel.moveToNextWeek,
                onSelectDay: { date in
                    selectedDay = date
                }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.studyDays.indices, id: \.self) { dayIndex in
                        let studyDay = viewModel.studyDays[dayIndex]
                        
                        if viewModel.selectedWeek.contains(where: { Calendar.current.isDate($0, inSameDayAs: studyDay.date) }) {
                            DayPlanView(
                                studyDay: studyDay,
                                onToggleTask: { taskIndex in
                                    viewModel.toggleTaskCompletion(dayIndex: dayIndex, taskIndex: taskIndex)
                                },
                                onEditTask: { taskIndex in
                                    selectedDay = studyDay.date
                                    showingAddTask = true
                                },
                                onDeleteTask: { taskIndex in
                                    showDeleteAlert = true
                                },
                                onAddTask: {
                                    selectedDay = studyDay.date
                                    showingAddTask = true
                                }
                            )
                        }
                    }
                    
                    // Show empty state if no days found in this week
                    if !viewModel.selectedWeek.contains(where: { date in
                        viewModel.studyDays.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
                    }) {
                        emptyStateView
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        VStack {
            HStack {
                Text("Derse Göre Filtrele:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Menu {
                    Button("Tüm Dersler") {
                        viewModel.filteredSubject = nil
                    }
                    
                    Divider()
                    
                    ForEach(viewModel.availableSubjects, id: \.self) { subject in
                        Button(subject) {
                            viewModel.filteredSubject = subject
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.filteredSubject ?? "Tüm Dersler")
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            List {
                let tasks = viewModel.tasksForSelectedWeek()
                
                if tasks.isEmpty {
                    Text("Bu haftaya ait görev bulunamadı")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(tasks) { task in
                        TaskListItemView(
                            task: task, 
                            onTap: {
                                if let dayIndex = viewModel.getDayIndex(for: task.startTime),
                                   let _ = viewModel.studyDays[dayIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                                    selectedDay = task.startTime
                                    showingAddTask = true
                                }
                            },
                            onToggle: {
                                if let dayIndex = viewModel.getDayIndex(for: task.startTime),
                                   let taskIndex = viewModel.studyDays[dayIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                                    viewModel.toggleTaskCompletion(dayIndex: dayIndex, taskIndex: taskIndex)
                                }
                            },
                            onDelete: {
                                showDeleteAlert = true
                            }
                        )
                    }
                }
            }
        }
    }
}


#Preview {
    StudyPlanView()
}
