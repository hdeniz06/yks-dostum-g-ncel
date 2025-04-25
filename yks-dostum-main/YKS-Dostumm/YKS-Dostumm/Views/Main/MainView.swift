import SwiftUI
import Combine

struct MainView: View {
    @StateObject private var drawerViewModel = DrawerViewModel()
    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Main Content Area
                contentView
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: drawerViewModel.isDrawerOpen ? 270 : 0)
                    .disabled(drawerViewModel.isDrawerOpen)
                    .animation(.spring(), value: drawerViewModel.isDrawerOpen)
                
                // Drawer
                if drawerViewModel.isDrawerOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            drawerViewModel.toggleDrawer()
                        }
                        .transition(.opacity)
                        .zIndex(1)
                }
                
                DrawerView(viewModel: drawerViewModel)
                    .frame(width: 270)
                    .offset(x: drawerViewModel.isDrawerOpen ? 0 : -270)
                    .animation(.spring(), value: drawerViewModel.isDrawerOpen)
                    .zIndex(2)
            }
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let safeAreaInsets = window.safeAreaInsets
                    self.safeAreaInsets = EdgeInsets(
                        top: safeAreaInsets.top,
                        leading: safeAreaInsets.left,
                        bottom: safeAreaInsets.bottom,
                        trailing: safeAreaInsets.right
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var contentView: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: {
                    drawerViewModel.toggleDrawer()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(drawerViewModel.selectedItem.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Notifications or profile action
                }) {
                    Image(systemName: "")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, safeAreaInsets.top)
            .padding(.bottom, 10)
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Content based on selected drawer item
            switch drawerViewModel.selectedItem {
            case .dashboard:
                EnhancedDashboardView()
            case .studyPlan:
                StudyPlanView()
            case .subjectTracking:
                KonuTakibiView()
            case .testResults:
                TestResultsView(viewModel: TestResultsViewModel())
            case .aiAssistant:
                ChatView()

            case .library:
                NearbyLibrariesView(viewModel: NearbyLibrariesViewModel())
            case .timers:
                TimersView(viewModel: TimersViewModel())
            case .settings:
                SettingsView(viewModel: SettingsViewModel())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    MainView()
}
