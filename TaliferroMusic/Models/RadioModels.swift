import Foundation

struct RadioChannel: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
}

struct RadioChannelsResponse: Codable {
    let channels: [RadioChannel]
}

struct NowPlaying: Codable {
    let track: String?
    let artist: String?
    let artUrl: String?
    let trackElapsedSec: Double?
    let trackDurationSec: Double?
}

struct RecentTrack: Codable, Identifiable {
    var id: String { startedAt + track }
    let track: String
    let artist: String
    let artUrl: String?
    let startedAt: String

    var startedAtDate: Date? {
        try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(startedAt)
    }
}

struct RecentlyPlayedResponse: Codable {
    let tracks: [RecentTrack]
}

struct ListenersResponse: Codable {
    let total: Int
}

struct FeaturedArtist: Identifiable {
    struct Link: Identifiable {
        var id: String { label }
        let label: String
        let url: URL
    }

    var id: String { name }
    let name: String
    let genres: String
    let links: [Link]
}

enum FeaturedArtists {
    static let all: [FeaturedArtist] = [
        FeaturedArtist(
            name: "Calima Shatiday",
            genres: "Downtempo • Chillout",
            links: [
                .init(label: "Apple Music", url: URL(string: "https://music.apple.com/us/artist/calima-shatiday/307747843")!),
                .init(label: "Spotify", url: URL(string: "https://open.spotify.com/artist/0dvd9DVM2vF5JIIVMQvzQm")!)
            ]
        ),
        FeaturedArtist(
            name: "Trestal",
            genres: "Electronic • Experimental",
            links: [
                .init(label: "Apple Music", url: URL(string: "https://music.apple.com/us/artist/trestal/306791410")!),
                .init(label: "Spotify", url: URL(string: "https://open.spotify.com/artist/52ZEBVXi2S20Tw7mqw1ijB")!)
            ]
        ),
        FeaturedArtist(
            name: "Kerboo",
            genres: "R&B • HipHop",
            links: [
                .init(label: "Apple Music", url: URL(string: "https://music.apple.com/us/artist/kerboo/673637442")!),
                .init(label: "Spotify", url: URL(string: "https://open.spotify.com/artist/1vQz9DbSIDoabSCxFNFnyT")!)
            ]
        ),
        FeaturedArtist(
            name: "B T S",
            genres: "Electronic • Dance Music",
            links: [
                .init(label: "Bandcamp", url: URL(string: "https://b-t-s.bandcamp.com/")!)
            ]
        ),
        FeaturedArtist(
            name: "Ty Showers",
            genres: "Jazz • Fusion",
            links: [
                .init(label: "Bandcamp", url: URL(string: "https://tyshowers.bandcamp.com/")!)
            ]
        )
    ]

    /// Links for a recently played track's artist, matched against the ID3 artist tag.
    static func links(for artist: String) -> [FeaturedArtist.Link] {
        all.first { $0.name.caseInsensitiveCompare(artist) == .orderedSame }?.links ?? []
    }
}
