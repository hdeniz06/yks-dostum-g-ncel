import SwiftUI

struct KonuTakibiView: View {
    @StateObject private var viewModel = KonuTakibiViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    // Animation properties
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.top)
                
                VStack(spacing: 0) {
                    // Search and filter bar
                    searchAndFilterBar
                    
                    if viewModel.categories.isEmpty {
                        emptyStateView
                    } else {
                        // Category and subject content
                        ScrollView {
                            VStack(spacing: 16) {
                                categoriesSection
                                
                                if let selectedCategory = viewModel.selectedCategory {
                                    subjectsSection(for: selectedCategory)
                                } else {
                                    Text("Lütfen bir kategori seçin")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                                
                                Spacer(minLength: 80) // Space for FAB
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Floating action buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButtons
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.showingAddCategorySheet = true }) {
                            Label("Yeni Kategori", systemImage: "folder.badge.plus")
                        }
                        
                        Menu("Sıralama: \(viewModel.sortOption.rawValue)") {
                            ForEach(SortOption.allCases) { option in
                                Button(option.rawValue) {
                                    viewModel.sortOption = option
                                }
                            }
                        }
                        
                        Menu("Filtre: \(viewModel.filterOption.rawValue)") {
                            ForEach(FilterOption.allCases) { option in
                                Button(option.rawValue) {
                                    viewModel.filterOption = option
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddCategorySheet) {
                addCategorySheet
            }
            .sheet(isPresented: $viewModel.showingAddSubjectSheet) {
                addSubjectSheet
            }
            .sheet(isPresented: $viewModel.showingEditSubjectSheet) {
               // editSubjectSheet
            }
        }
    }
    
    // MARK: - UI Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.systemBackground).opacity(0.95),
                Color(UIColor.secondarySystemBackground).opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Konu ara...", text: $viewModel.searchText)
                    .font(.body)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterOption.allCases) { option in
                        FilterChip(
                            title: option.rawValue,
                            isSelected: viewModel.filterOption == option,
                            action: { viewModel.filterOption = option }
                        )
                    }
                    
                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 4)
                    
                    ForEach(SortOption.allCases) { option in
                        FilterChip(
                            title: option.rawValue,
                            isSelected: viewModel.sortOption == option,
                            action: { viewModel.sortOption = option }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategoriler")
                .font(.headline)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryCard(category: category, isSelected: viewModel.selectedCategory?.id == category.id)
                            .matchedGeometryEffect(id: category.id, in: animation)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    viewModel.selectedCategory = category
                                }
                            }
                    }
                }
                .padding(.bottom, 4) // Prevent clipping of shadows
            }
        }
    }
    
    private func subjectsSection(for category: KonuKategori) -> some View {
        let subjects = viewModel.filteredSubjectsForCategory(category)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(category.name) Konuları")
                    .font(.headline)
                
                Spacer()
                
                Text("\(subjects.count) konu")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            if subjects.isEmpty {
                emptySubjectsView
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 300), spacing: 16)
                ], spacing: 16) {
                    ForEach(subjects) { subject in
                        SubjectCard(subject: subject, category: category, viewModel: viewModel)
                            .contextMenu {
                                Button(action: {
                                    viewModel.selectedSubject = subject
                                    viewModel.showingEditSubjectSheet = true
                                }) {
                                    Label("Düzenle", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    viewModel.deleteSubject(subject, from: category)
                                }) {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "list.clipboard")
                .font(.system(size: 70))
                .foregroundColor(.secondary)
                .padding()
            
            Text("Henüz bir kategori yok")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("YKS çalışmalarınızı takip etmek için kategoriler ekleyin")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { viewModel.showingAddCategorySheet = true }) {
                Text("Kategori Ekle")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var emptySubjectsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding()
            
            Text("Bu kategoride konu yok")
                .font(.headline)
            
            Text("Yeni konu eklemek için aşağıdaki + butonuna dokunun")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { viewModel.showingAddSubjectSheet = true }) {
                Label("Konu Ekle", systemImage: "plus")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private var floatingActionButtons: some View {
        VStack(spacing: 12) {
            if viewModel.selectedCategory != nil {
                Button(action: { viewModel.showingAddSubjectSheet = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .padding()
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(radius: 2, x: 0, y: 2)
                }
            }
        }
    }
    
    // MARK: - Sheets
    
    private var addCategorySheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Yeni Kategori"), content: {
                    TextField("Kategori Adı", text: $viewModel.newCategoryName)
                        .autocapitalization(.words)
                })
            }
            .navigationTitle("Kategori Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        viewModel.newCategoryName = ""
                        viewModel.showingAddCategorySheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        viewModel.addCategory()
                        viewModel.showingAddCategorySheet = false
                    }
                    .disabled(viewModel.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var addSubjectSheet: some View {
        NavigationView {
            Form {
                if let selectedCategory = viewModel.selectedCategory {
                    Text("\(selectedCategory.name) kategorisine yeni konu ekleniyor")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                    
                    Section(header: Text("Konu Bilgileri"), content: {
                        TextField("Konu Adı", text: $viewModel.newSubjectName)
                            .autocapitalization(.words)
                        Picker("Sınav Tipi", selection: $viewModel.selectedExamType) {
                            ForEach(ExamType.allCases, id: \.self) { examType in
                                Text(examType.rawValue).tag(examType)
                            }
                        }
                        HStack {
                            Text("Toplam Alt Konu")
                            Spacer()
                            TextField("", text: $viewModel.newSubjectTopics)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                        }
                        HStack {
                            Text("Tamamlanan Alt Konu")
                            Spacer()
                            TextField("", text: $viewModel.newSubjectCompleted)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                        }
                    })
                    
                    Section(header: Text("Notlar"), content: {
                        TextEditor(text: $viewModel.newSubjectNotes)
                            .frame(minHeight: 100)
                    })
                }
            }
            .navigationTitle("Yeni Konu Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        viewModel.resetNewSubjectForm()
                        viewModel.showingAddSubjectSheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        if let category = viewModel.selectedCategory {
                            viewModel.addSubject(to: category)
                        }
                        viewModel.showingAddSubjectSheet = false
                    }
                    .disabled(viewModel.newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
//    private var editSubjectSheet: some View {
//        NavigationView {
//            Form {
//                if let subject = viewModel.selectedSubject {
//                    Section(header: Text("Konu Bilgileri"), content: {
//                        TextField("Konu Adı", text: Binding(
//                            get: { subject.name },
//                            set: { viewModel.selectedSubject?.name = $0 }
//                        ))
//                        Picker("Sınav Tipi", selection: Binding(
//                            get: { subject.examType },
//                            set: { viewModel.selectedSubject?.examType = $0 }
//                        )) {
//                            ForEach(ExamType.allCases, id: \.self) { exam in
//                                Text(exam.rawValue).tag(exam)
//                            }
//                        }
//                        HStack {
//                            Text("Toplam Alt Konu")
//                            Spacer()
//                            TextField("", text: Binding(
//                                get: { String(subject.topics) },
//                                set: { viewModel.selectedSubject?.topics = Int($0) ?? 0 }
//                            ))
//                            .keyboardType(.numberPad)
//                        }
//                        HStack {
//                            Text("Tamamlanan Alt Konu")
//                            Spacer()
//                            TextField("", text: Binding(
//                                get: { String(subject.completed) },
//                                set: { viewModel.selectedSubject?.completed = Int($0) ?? 0 }
//                            ))
//                            .keyboardType(.numberPad)
//                        }
//                    })
//                    Section(header: Text("Notlar"), content: {
//                        TextEditor(text: Binding(
//                            get: { subject.notes },
//                            set: { viewModel.selectedSubject?.notes = $0 }
//                        ))
//                        .frame(minHeight: 100)
//                    })
//                }
//            }
//            .navigationTitle("Konu Düzenle")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("İptal") { viewModel.showingEditSubjectSheet = false }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Kaydet") {
//                        viewModel.saveEditedSubject()
//                        viewModel.showingEditSubjectSheet = false
//                    }
//                }
//            }
//        }
//    }
}

// MARK: - Supporting Views

struct CategoryCard: View {
    let category: KonuKategori
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                Text("\(category.subjects.count)")
                    .font(.caption)
                    .padding(6)
                    .background(Circle().fill(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2)))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.orange : Color(UIColor.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.orange : Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.05), radius: 3, x: 0, y: 1)
    }
}

struct SubjectCard: View {
    let subject: KonuTakibi
    let category: KonuKategori
    @ObservedObject var viewModel: KonuTakibiViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(subject.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(subject.examType.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(Capsule().fill(subject.examType.color.opacity(0.2)))
                    .foregroundColor(subject.examType.color)
            }
            
            Divider()
            
            // Progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(subject.progressFormatted) tamamlandı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(subject.progress * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(subject.isCompleted ? .green : .primary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 6)
                        
                        // Foreground
                        RoundedRectangle(cornerRadius: 3)
                            .fill(subject.isCompleted ? Color.green : subject.examType.color)
                            .frame(width: max(0, CGFloat(subject.progress) * geometry.size.width), height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            // Last studied date
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(subject.lastStudyDateFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            
            // Controls
            HStack {
                if !subject.isCompleted {
                    Button(action: {
                        viewModel.incrementCompletedTopics(for: subject, in: category)
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("+1 Tamamla")
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.green.opacity(0.2)))
                        .foregroundColor(.green)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                // Notes indicator
                if !subject.notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(UIColor.tertiarySystemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Required for Binding<SortOption> and Binding<FilterOption>
typealias SortOption = KonuTakibiViewModel.SortOption
typealias FilterOption = KonuTakibiViewModel.FilterOption

#Preview {
    KonuTakibiView()
}
