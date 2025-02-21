import SwiftUI

@main
struct FOMOApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    HomeView()
                }

                Tab("Saved", systemImage: "bookmark") {
                    Text("Helloworld")
                }
            }
        }
    }
}
