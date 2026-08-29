import SwiftUI

struct RadioView: View {
    @StateObject private var viewModel: RadioViewModel
    @State private var isSharePresented = false
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
    }

    private var portraitLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                listenNowCard
                featuredCard
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
                    featuredCard
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

                Spacer()
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
        }
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

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FEATURED")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.muted)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(FeaturedArtists.all.enumerated()), id: \.element.id) { index, artist in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(artist.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.text)
                        Text(artist.genres)
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                        HStack(spacing: 14) {
                            ForEach(artist.links) { link in
                                Link(link.label, destination: link.url)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 12)

                    if index < FeaturedArtists.all.count - 1 {
                        Divider().background(Theme.divider)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
    }

    private var footer: some View {
        HStack {
            Text(verbatim: "© \(currentYear) Taliferro Music")
                .font(.caption2)
                .foregroundStyle(Theme.muted)
            Spacer()
            NavigationLink("About") {
                AboutView()
            }
            .font(.caption2)
            .foregroundStyle(Theme.muted)
        }
        .padding(.top, 4)
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}
