import Foundation

enum RadioAPIError: LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server response could not be understood."
        case .httpError(let code):
            return "The server returned HTTP \(code)."
        }
    }
}

final class RadioAPIClient {
    private let config: AppConfig
    private let decoder = JSONDecoder()

    init(config: AppConfig) {
        self.config = config
    }

    var defaultCoverArtURL: URL? {
        config.apiBaseURL.appending(path: "assets/cover.jpg")
    }

    func fetchChannels() async throws -> [RadioChannel] {
        let response: RadioChannelsResponse = try await get(path: "channels")
        return response.channels
    }

    func fetchNowPlaying(channel: String) async throws -> NowPlaying {
        try await get(path: "now-playing/\(channel)")
    }

    func streamURL(forChannel channel: String) -> URL {
        config.apiBaseURL.appending(path: "hls/\(channel)/index.m3u8")
    }

    private func get<Response: Decodable>(path: String) async throws -> Response {
        var request = URLRequest(url: config.apiBaseURL.appending(path: path))
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RadioAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RadioAPIError.httpError(httpResponse.statusCode)
        }

        return try decoder.decode(Response.self, from: data)
    }
}
