import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingProfileEdit = false
    @State private var tempName = ""
    @State private var tempEmail = ""
    
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
                        
                        Button(action: {
                            tempName = viewModel.userName
                            tempEmail = viewModel.userEmail
                            showingProfileEdit = true
                        }) {
                            Text("Düzenle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Profile Content
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(viewModel.userName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
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
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(
                name: $tempName,
                email: $tempEmail,
                onSave: {
                    viewModel.updateUserName(tempName)
                    viewModel.updateUserEmail(tempEmail)
                }
            )
        }
    }
}

struct ProfileEditView: View {
    @Binding var name: String
    @Binding var email: String
    let onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Bilgileri")) {
                    TextField("Ad Soyad", text: $name)
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

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
