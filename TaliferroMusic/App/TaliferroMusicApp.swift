import SwiftUI

@main
struct TaliferroMusicApp: App {
    private let apiClient = RadioAPIClient(config: .fromBundle())
    private let player = AudioPlayerService()

    var body: some Scene {
        WindowGroup {
            RadioView(apiClient: apiClient, player: player)
        }
    }
}
