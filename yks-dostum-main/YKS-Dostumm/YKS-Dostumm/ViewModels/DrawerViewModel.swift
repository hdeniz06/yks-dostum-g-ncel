import Foundation
import SwiftUI
import Combine

class DrawerViewModel: ObservableObject {
    @Published var selectedItem: DrawerItemType = .dashboard
    @Published var isDrawerOpen: Bool = false
    
    // Toggle drawer state
    func toggleDrawer() {
        withAnimation(.spring()) {
            isDrawerOpen.toggle()
        }
    }
    
    // Select a drawer item
    func selectItem(_ item: DrawerItemType) {
        withAnimation {
            self.selectedItem = item
            // Close drawer after selection on smaller devices
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.isDrawerOpen = false
            }
        }
    }
}
