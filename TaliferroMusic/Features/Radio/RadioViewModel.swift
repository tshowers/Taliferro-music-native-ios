import Foundation
import Combine
import UIKit
import MediaPlayer

@MainActor
final class RadioViewModel: ObservableObject {
    @Published private(set) var channels: [RadioChannel] = []
    @Published private(set) var currentChannel: String?
    @Published private(set) var track = "Station warm-up"
    @Published private(set) var artist = "Taliferro Music"
    @Published private(set) var artworkImage: UIImage?
    @Published private(set) var progress: Double = 0
    @Published private(set) var status = "Idle"
    @Published private(set) var isPlaying = false
    @Published private(set) var recentTracks: [RecentTrack] = []
    /// Station-wide listener count, nil until it reaches `listenerMinShown`.
    @Published private(set) var listenerCount: Int?
    @Published private(set) var sleepMinutes: Int?
    @Published private(set) var sleepRemaining: String?

    static let sleepOptions = [15, 30, 45, 60]

    private let apiClient: RadioAPIClient
    private let player: AudioPlayerService
    private var cancellables = Set<AnyCancellable>()

    private let channelKey = "tm-channel"
    private var pollTask: Task<Void, Never>?
    private var progressTimer: Timer?
    private var elapsedAtFetch: Double = 0
    private var durationSec: Double = 0
    private var fetchedAt = Date()
    private var artworkCache: [String: UIImage] = [:]
    private var lastTrackKey: String?
    private var listenersTask: Task<Void, Never>?
    private var sleepEndsAt: Date?

    private let recentLimit = 10
    private let listenerMinShown = 8

    private let fallbackChannels = ["Downtempo", "Groove", "Jazzy"].map { RadioChannel(name: $0) }

    init(apiClient: RadioAPIClient, player: AudioPlayerService) {
        self.apiClient = apiClient
        self.player = player

        player.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.isPlaying = $0 }
            .store(in: &cancellables)

        player.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.status = $0 }
            .store(in: &cancellables)

        // Background audio keeps the app running while the stream plays, so this
        // keeps ticking with the screen locked — which is what the sleep timer needs.
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tickProgress()
                self?.tickSleep()
            }
        }
    }

    func start() async {
        listenersTask?.cancel()
        listenersTask = Task { [weak self] in
            await self?.pollListenersLoop()
        }

        do {
            let fetched = try await apiClient.fetchChannels()
            channels = fetched.isEmpty ? fallbackChannels : fetched
        } catch {
            channels = fallbackChannels
        }

        let saved = UserDefaults.standard.string(forKey: channelKey)
        let initial = channels.first(where: { $0.name == saved })?.name ?? channels.first?.name
        if let initial {
            await selectChannel(initial)
        }
    }

    func selectChannel(_ name: String) async {
        guard name != currentChannel else { return }
        currentChannel = name
        UserDefaults.standard.set(name, forKey: channelKey)

        elapsedAtFetch = 0
        durationSec = 0
        fetchedAt = Date()
        progress = 0
        lastTrackKey = nil
        recentTracks = []

        player.play(url: apiClient.streamURL(forChannel: name))

        pollTask?.cancel()
        pollTask = Task { [weak self] in
            await self?.pollNowPlayingLoop(channel: name)
        }
    }

    func togglePlayPause() {
        player.togglePlayPause()
    }

    var shareURL: URL {
        URL(string: "https://music.taliferro.com")!
    }

    // MARK: Sleep timer

    func setSleepTimer(minutes: Int?) {
        sleepMinutes = minutes
        sleepEndsAt = minutes.map { Date().addingTimeInterval(Double($0) * 60) }
        tickSleep()
    }

    private func tickSleep() {
        guard let sleepEndsAt else {
            sleepRemaining = nil
            return
        }
        let remaining = Int(sleepEndsAt.timeIntervalSinceNow.rounded(.up))
        if remaining <= 0 {
            setSleepTimer(minutes: nil)
            player.fadeOutAndPause()
            return
        }
        sleepRemaining = String(format: "%d:%02d", remaining / 60, remaining % 60)
    }

    // MARK: Recently played + listeners

    private func refreshRecentlyPlayed(channel: String) async {
        guard let tracks = try? await apiClient.fetchRecentlyPlayed(channel: channel, limit: recentLimit),
              channel == currentChannel else { return }
        recentTracks = tracks
    }

    private func pollListenersLoop() async {
        while !Task.isCancelled {
            if let total = try? await apiClient.fetchListenerCount() {
                listenerCount = total >= listenerMinShown ? total : nil
            } else {
                listenerCount = nil
            }
            try? await Task.sleep(nanoseconds: 30_000_000_000)
        }
    }

    private func pollNowPlayingLoop(channel: String) async {
        while !Task.isCancelled {
            await refreshNowPlaying(channel: channel)
            try? await Task.sleep(nanoseconds: 15_000_000_000)
        }
    }

    private func refreshNowPlaying(channel: String) async {
        do {
            let info = try await apiClient.fetchNowPlaying(channel: channel)
            track = (info.track?.isEmpty == false) ? info.track! : "Live"
            artist = (info.artist?.isEmpty == false) ? info.artist! : "Taliferro Music"
            elapsedAtFetch = info.trackElapsedSec ?? 0
            durationSec = info.trackDurationSec ?? 0
            fetchedAt = Date()
            tickProgress()

            await loadArtwork(urlString: info.artUrl)
            publishNowPlayingInfo()

            // A new track means the previous one just joined "recently played".
            let trackKey = "\(channel)|\(track)|\(artist)"
            if trackKey != lastTrackKey {
                lastTrackKey = trackKey
                await refreshRecentlyPlayed(channel: channel)
            }
        } catch {
            // Keep the last known now-playing info; the stream's own status
            // reporting is what surfaces connectivity problems to the user.
        }
    }

    private func tickProgress() {
        guard durationSec > 0 else {
            progress = 0
            return
        }
        let elapsed = elapsedAtFetch + Date().timeIntervalSince(fetchedAt)
        progress = min(max(elapsed / durationSec, 0), 1)
    }

    private func loadArtwork(urlString: String?) async {
        let resolved = (urlString?.isEmpty == false) ? urlString! : apiClient.defaultCoverArtURL?.absoluteString
        guard let resolved, let url = URL(string: resolved) else { return }

        if let cached = artworkCache[resolved] {
            artworkImage = cached
            return
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }

        artworkCache[resolved] = image
        artworkImage = image
    }

    private func publishNowPlayingInfo() {
        let artwork = artworkImage.map { image in
            MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        player.updateNowPlayingInfo(
            title: track,
            artist: artist,
            artwork: artwork,
            elapsed: elapsedAtFetch,
            duration: durationSec
        )
    }

    deinit {
        pollTask?.cancel()
        listenersTask?.cancel()
        progressTimer?.invalidate()
    }
}
