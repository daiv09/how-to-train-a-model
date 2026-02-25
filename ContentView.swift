import SwiftUI

struct ContentView: View {
    // MARK: - State Objects
    @State private var hasSeenOnboarding = false
    
    @StateObject private var dataset = DatasetModel()

    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                NavigationStack {
                    CollectorView()
                }
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
        .environmentObject(dataset)
    }
}
