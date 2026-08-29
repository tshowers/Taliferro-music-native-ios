import Foundation

struct AppConfig {
    let apiBaseURL: URL

    static func fromBundle(bundle: Bundle = .main) -> AppConfig {
        let baseURLString = bundle.object(forInfoDictionaryKey: "RADIO_API_BASE_URL") as? String ?? ""
        let resolved = baseURLString.isEmpty ? "https://radio.taliferro.com" : baseURLString

        guard let apiBaseURL = URL(string: resolved) else {
            fatalError("Missing or invalid RADIO_API_BASE_URL.")
        }

        return AppConfig(apiBaseURL: apiBaseURL)
    }
}
