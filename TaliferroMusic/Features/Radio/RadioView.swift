import SwiftUI

struct RadioView: View {
    @StateObject private var viewModel: RadioViewModel
    @State private var isSharePresented = false
    @State private var isMenuPresented = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(apiClient: RadioAPIClient, player: AudioPlayerService) {
        _viewModel = StateObject(wrappedValue: RadioViewModel(apiClient: apiClient, player: player))
    }

    var body: some View {
        NavigationStack {
            Group {
                if verticalSizeClass == .compact {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .background(Theme.background.ignoresSafeArea())
        }
        .task { await viewModel.start() }
        .sheet(isPresented: $isSharePresented) {
            ShareSheet(items: [viewModel.shareURL])
        }
        .sheet(isPresented: $isMenuPresented) {
            StationMenuView()
        }
    }

    private var portraitLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                listenNowCard
                recentlyPlayedCard
                footer
            }
            .padding(20)
        }
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    listenNowCard
                    footer
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    recentlyPlayedCard
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Taliferro Music Radio")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.text)
                Text("Press play and let it ride.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Text("LIVE · 24/7")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Button {
                    isMenuPresented = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.text)
                        .frame(width: 36, height: 36)
                        .background(Circle().stroke(Theme.divider, lineWidth: 1))
                }
                .accessibilityLabel("Menu")

                Button {
                    isSharePresented = true
                } label: {
                    Text("Copy link")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().stroke(Theme.divider, lineWidth: 1))
                }
            }
        }
    }

    private var listenNowCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("LISTEN NOW")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                Spacer()
                statusPill
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("MOOD")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.channels) { channel in
                            moodChip(channel.name)
                        }
                    }
                }
            }

            nowPlayingRow
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.accent)
                .frame(width: 6, height: 6)
            Text(viewModel.status)
                .font(.caption)
                .foregroundStyle(Theme.text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Theme.surfaceAlt))
    }

    private func moodChip(_ name: String) -> some View {
        let isSelected = name == viewModel.currentChannel
        return Button {
            Task { await viewModel.selectChannel(name) }
        } label: {
            Text(name.capitalized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(isSelected ? Theme.accentInk : Theme.text)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? Theme.accent : Theme.surfaceAlt)
                )
        }
    }

    private var nowPlayingRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                artworkView
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    viewModel.togglePlayPause()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(Theme.accentInk)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Theme.accent))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.track)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    Text(viewModel.artist)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                sleepTimerMenu
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceAlt)
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: proxy.size.width * viewModel.progress)
                }
            }
            .frame(height: 3)

            if let count = viewModel.listenerCount {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 6, height: 6)
                    Text("\(count) people are listening now")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.muted)
                }
                .padding(.top, 2)
            }
        }
    }

    private var sleepTimerMenu: some View {
        let isActive = viewModel.sleepRemaining != nil
        return Menu {
            Section("Stop playback after") {
                ForEach(RadioViewModel.sleepOptions, id: \.self) { minutes in
                    Button {
                        viewModel.setSleepTimer(minutes: minutes)
                    } label: {
                        if viewModel.sleepMinutes == minutes {
                            Label("\(minutes) minutes", systemImage: "checkmark")
                        } else {
                            Text("\(minutes) minutes")
                        }
                    }
                }
            }
            if isActive {
                Button("Turn Off Sleep Timer", role: .destructive) {
                    viewModel.setSleepTimer(minutes: nil)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "moon")
                Text(viewModel.sleepRemaining ?? "Sleep")
                    .monospacedDigit()
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isActive ? Theme.accent : Theme.muted)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().stroke(isActive ? Theme.accent.opacity(0.45) : Theme.divider, lineWidth: 1))
        }
        .accessibilityLabel(isActive ? "Sleep timer, stops in \(viewModel.sleepRemaining ?? "")" : "Sleep timer")
    }

    private var artworkView: some View {
        Group {
            if let image = viewModel.artworkImage {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Rectangle().fill(Theme.surfaceAlt)
            }
        }
    }

    private var recentlyPlayedCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RECENTLY PLAYED")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.muted)

            if viewModel.recentTracks.isEmpty {
                Text("Songs show up here as they finish playing.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(viewModel.recentTracks.enumerated()), id: \.element.id) { index, item in
                        recentRow(item)
                            .padding(.vertical, 10)

                        if index < viewModel.recentTracks.count - 1 {
                            Divider().background(Theme.divider)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
    }

    private func recentRow(_ item: RecentTrack) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: item.artUrl.flatMap(URL.init(string:))) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Theme.surfaceAlt)
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.track)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    if let date = item.startedAtDate {
                        Text(date, format: .dateTime.hour().minute())
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(Theme.faint)
                    }
                }
                HStack(spacing: 12) {
                    Text(item.artist)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                    ForEach(FeaturedArtists.links(for: item.artist)) { link in
                        Link(link.label, destination: link.url)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
        }
    }

    private var footer: some View {
        Text(verbatim: "© \(currentYear) Taliferro Music")
            .font(.caption2)
            .foregroundStyle(Theme.muted)
            .padding(.top, 4)
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}
