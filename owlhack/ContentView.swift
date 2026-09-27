import SwiftUI

struct ContentView: View {

    var body: some View {

        TabView {

            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage:
                            "house.fill"
                    )
                }

            VitalsView()
                .tabItem {
                    Label(
                        "Vitals",
                        systemImage:
                            "heart.text.square.fill"
                    )
                }

            SelfieView()
                .tabItem {
                    Label(
                        "Selfie",
                        systemImage:
                            "camera.fill"
                    )
                }
            GalleryView()
                .tabItem {
                    Label(
                        "Gallery",
                        systemImage:
                            "photo.on.rectangle.angled"
                    )
                }
        }
    }
}
