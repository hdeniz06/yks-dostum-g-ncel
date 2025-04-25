import SwiftUI
import MapKit

struct NearbyLibrariesView: View {
    @ObservedObject var viewModel: NearbyLibrariesViewModel
    @State private var showingLibraryDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Map View
            ZStack(alignment: .bottomTrailing) {
                Map {
                    ForEach(viewModel.libraries) { library in
                        Annotation(library.name, coordinate: library.coordinate) {
                            VStack {
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 36, height: 36)
                                    )
                                    .shadow(radius: 2)
                                
                                if viewModel.selectedLibrary?.id == library.id {
                                    Text(library.name)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(5)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(5)
                                        .shadow(radius: 1)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: 150)
                                }
                            }
                            .onTapGesture {
                                viewModel.selectLibrary(library)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                // Refresh button
                Button(action: {
                    viewModel.searchNearbyLibraries()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding()
            }
            .frame(height: 300)
            
            // Status message
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .padding(.trailing, 5)
                    Text("Kütüphaneler aranıyor...")
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
            } else {
                switch viewModel.locationStatus {
                case .denied:
                    LocationPermissionView {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                case .error(let message):
                    Text(message)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                default:
                    if !viewModel.libraries.isEmpty {
                        HStack {
                            Text("\(viewModel.libraries.count) kütüphane bulundu")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("5 km içinde")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemBackground))
                    }
                }
            }
            
            // Libraries List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.libraries) { library in
                        LibraryItemView(
                            library: library,
                            distance: viewModel.formatDistance(library.distance),
                            isSelected: viewModel.selectedLibrary?.id == library.id,
                            onSelect: {
                                viewModel.selectLibrary(library)
                                showingLibraryDetail = true
                            }
                        )
                    }
                    
                    if viewModel.libraries.isEmpty && !viewModel.isLoading && !viewModel.locationStatus.isDenied {
                        VStack(spacing: 15) {
                            Image(systemName: "building.columns")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Yakınınızda kütüphane bulunamadı")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                viewModel.searchNearbyLibraries()
                            }) {
                                Text("Tekrar Ara")
                                    .font(.subheadline)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Yakınımdaki Kütüphaneler")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingLibraryDetail) {
            if let library = viewModel.selectedLibrary {
                LibraryDetailView(
                    library: library,
                    distance: viewModel.formatDistance(library.distance),
                    onGetDirections: {
                        viewModel.getDirections(to: library)
                    }
                )
            }
        }
        .onAppear {
            viewModel.checkLocationAuthorization()
        }
    }
}

struct LibraryItemView: View {
    let library: Library
    let distance: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 15) {
                // Library Icon
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(library.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(library.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color(UIColor.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LibraryDetailView: View {
    let library: Library
    let distance: String
    let onGetDirections: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Library Header
                    VStack(alignment: .center, spacing: 15) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                            .frame(width: 80, height: 80)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(15)
                        
                        Text(library.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            
                            Text(distance)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                    
                    // Address
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Adres")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(library.address)
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // Phone Number
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Telefon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            if let url = URL(string: "tel:\(library.phoneNumber.replacingOccurrences(of: " ", with: ""))"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                
                                Text(library.phoneNumber)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "phone.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        .disabled(library.phoneNumber == "Telefon bilgisi yok")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // Get Directions Button
                    Button(action: onGetDirections) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.white)
                            
                            Text("Yol Tarifi Al")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Kütüphane Detayı", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Kapat")
                }
            )
        }
    }
}

struct LocationPermissionView: View {
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Konum İzni Gerekli")
                .font(.headline)
            
            Text("Yakınındaki kütüphaneleri görebilmek için konum izni vermeniz gerekiyor.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onOpenSettings) {
                Text("Ayarları Aç")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 5)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        NearbyLibrariesView(viewModel: NearbyLibrariesViewModel())
    }
}
