import SwiftUI

@main
struct SpadesApp: App {
    var body: some Scene {
        WindowGroup {
            let rootView = ContentView()
                .preferredColorScheme(.dark)
#if os(iOS)
                .statusBarHidden(true)
#endif
            rootView
        }
    }
}
