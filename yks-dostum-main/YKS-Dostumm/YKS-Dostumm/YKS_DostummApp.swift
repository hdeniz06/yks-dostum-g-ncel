//
//  YKS_DostummApp.swift
//  YKS-Dostumm
//
//  Created by Mehmet Tuna Arıkaya on 16.04.2025.
//

import SwiftUI
import BackgroundTasks

@main
struct YKS_DostummApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
