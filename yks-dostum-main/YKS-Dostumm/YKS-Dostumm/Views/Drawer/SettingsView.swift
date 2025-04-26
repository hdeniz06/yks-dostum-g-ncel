import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingProfileEdit = false
    @State private var tempName = ""
    @State private var tempEmail = ""
    @State private var showingImagePicker = false
    @State private var pickedImage: UIImage? = nil
    @State private var showingPhotoOptions = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Section
                VStack(spacing: 15) {
                    // Profile Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Profil")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    // Profile Content
                    HStack(spacing: 15) {
                        ZStack {
                            if let data = viewModel.profileImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                        }
                        .onTapGesture {
                            showingPhotoOptions = true
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            TextField("Ad Soyad", text: $tempName, onCommit: {
                                viewModel.updateUserName(tempName)
                            })
                            .font(.title3)
                            .fontWeight(.semibold)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .onAppear {
                                tempName = viewModel.userName
                            }
                            if !viewModel.userEmail.isEmpty {
                                Text(viewModel.userEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Appearance Section
                VStack(spacing: 15) {
                    // Section Header
                    HStack {
                        Text("Görünüm")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Dark Mode Toggle
                    Toggle(isOn: $viewModel.isDarkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                            Text("Karanlık Mod")
                        }
                    }
                    .onChange(of: viewModel.isDarkMode) { oldValue, newValue in
                        viewModel.toggleDarkMode()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Notifications Section
                VStack(spacing: 15) {
                    // Section Header
                    HStack {
                        Text("Bildirimler")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Notifications Toggle
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text("Bildirimlere İzin Ver")
                        }
                    }
                    .onChange(of: viewModel.notificationsEnabled) { oldValue, newValue in
                        viewModel.toggleNotifications()
                    }
                    
                    // Daily Reminder Time (only shown if notifications are enabled)
                    if viewModel.notificationsEnabled {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Günlük Hatırlatma Saati")
                                .font(.subheadline)
                            
                            DatePicker(
                                "Hatırlatma Saati",
                                selection: $viewModel.dailyReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .onChange(of: viewModel.dailyReminderTime) { oldValue, newValue in
                                viewModel.updateReminderTime(newValue)
                            }
                        }
                        .padding(.top, 5)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // About Section
                VStack(spacing: 15) {
                    // Section Header
                    HStack {
                        Text("Hakkında")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // App Version
                    HStack {
                        Text("Uygulama Versiyonu")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    // Developer Info
                    HStack {
                        Text("Geliştirici")
                        Spacer()
                        Text("YKS Dostum Ekibi")
                            .foregroundColor(.secondary)
                    }
                    
                    // Contact
                    Button(action: {
                        // Open mail app with support email
                        if let url = URL(string: "mailto:support@yksdostum.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("İletişim")
                            Spacer()
                            Text("support@yksdostum.com")
                                .foregroundColor(.blue)
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Privacy Policy
                    Button(action: {
                        // Open privacy policy
                        if let url = URL(string: "https://www.yksdostum.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Gizlilik Politikası")
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Terms of Service
                    Button(action: {
                        // Open terms of service
                        if let url = URL(string: "https://www.yksdostum.com/terms") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Kullanım Koşulları")
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Reset Settings Button
                Button(action: {
                    viewModel.resetSettings()
                }) {
                    Text("Ayarları Sıfırla")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
            .padding()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 80, height: 80)
                    )
            }
        }
        .confirmationDialog("Profil Fotoğrafı", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
            Button("Fotoğrafı Değiştir", role: .none) {
                showingImagePicker = true
            }
            if viewModel.profileImageData != nil {
                Button("Fotoğrafı Kaldır", role: .destructive) {
                    viewModel.clearProfileImage()
                }
            }
            Button("İptal", role: .cancel) {}
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(
                email: $tempEmail,
                onSave: {
                    viewModel.updateUserEmail(tempEmail)
                }
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ProfileImagePicker(image: $pickedImage) { img in
                if let data = img.jpegData(compressionQuality: 0.8) {
                    viewModel.updateProfileImage(data)
                }
            }
        }
    }
}

struct ProfileEditView: View {
    @Binding var email: String
    let onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Bilgileri")) {
                    TextField("E-posta", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ProfileImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ProfileImagePicker
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.image = uiImage
                        self.parent.onImagePicked(uiImage)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
