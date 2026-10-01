import AVFoundation
import MediaPlayer

@MainActor
final class AudioPlayerService: NSObject, ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var status = "Idle"

    private var player: AVPlayer?
    private var itemStatusObserver: NSKeyValueObservation?
    private var timeControlObserver: NSKeyValueObservation?
    private var interruptionObserver: NSObjectProtocol?

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
        observeInterruptions()
    }

    func play(url: URL) {
        teardownPlayer()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer
        status = "Buffering"

        itemStatusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self, self.player === newPlayer else { return }
                if item.status == .failed {
                    self.status = "Stream error"
                }
            }
        }

        timeControlObserver = newPlayer.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                guard let self, self.player === newPlayer else { return }
                switch player.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.status = "Playing"
                case .paused:
                    self.isPlaying = false
                    self.status = "Paused"
                case .waitingToPlayAtSpecifiedRate:
                    self.status = "Buffering"
                @unknown default:
                    break
                }
            }
        }

        newPlayer.play()
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    /// Sleep timer ending: ramp the volume down, pause, then restore the volume
    /// so the next play starts at normal level.
    func fadeOutAndPause(over seconds: Double = 6) {
        guard let player, isPlaying else { return }
        let steps = 20
        Task { @MainActor in
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: UInt64(seconds / Double(steps) * 1_000_000_000))
                guard self.player === player else { return }
                player.volume = 1 - Float(step) / Float(steps)
            }
            player.pause()
            player.volume = 1
        }
    }

    func updateNowPlayingInfo(title: String, artist: String, artwork: MPMediaItemArtwork?, elapsed: Double, duration: Double) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyIsLiveStream: duration == 0
        ]
        if let artwork {
            info[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            status = "Audio session error"
        }
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
    }

    private func observeInterruptions() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let info = notification.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

            switch type {
            case .began:
                break // AVPlayer already pauses automatically when interrupted.
            case .ended:
                let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
                if AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                    Task { @MainActor in self.play() }
                }
            @unknown default:
                break
            }
        }
    }

    private func teardownPlayer() {
        itemStatusObserver?.invalidate()
        timeControlObserver?.invalidate()
        player?.pause()
        player = nil
    }

    deinit {
        itemStatusObserver?.invalidate()
        timeControlObserver?.invalidate()
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
    }
}
