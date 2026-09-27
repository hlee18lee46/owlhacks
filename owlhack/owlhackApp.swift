import SwiftUI

@main
struct owlhackApp: App {

    @StateObject
    private var appState =
        WhatTheHootState()

    var body: some Scene {

        WindowGroup {

            ContentView()
                .environmentObject(
                    appState
                )
        }
    }
}
