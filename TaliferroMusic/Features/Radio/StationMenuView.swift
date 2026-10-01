import SwiftUI

/// Mirrors the web player's menu: Featured artists plus the About link, moved
/// off the main screen so Recently played can take Featured's place.
struct StationMenuView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    featuredCard
                    aboutLink
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FEATURED ARTISTS")
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

    private var aboutLink: some View {
        NavigationLink {
            AboutView()
        } label: {
            HStack {
                Text("About Taliferro Music Radio")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
        }
    }
}
