import Foundation

struct StationFact: Identifiable {
    var id: String { label }
    let label: String
    let value: String
    let url: URL?

    init(label: String, value: String, url: URL? = nil) {
        self.label = label
        self.value = value
        self.url = url
    }
}

struct SocialLink: Identifiable {
    var id: String { label }
    let label: String
    let url: URL
}

struct AboutTool: Identifiable {
    var id: String { name }
    let name: String
    let description: String
    let iconURL: URL
    let ctaLabel: String
    let ctaURL: URL
    let caption: String
}

enum StationInfo {
    static let facts: [StationFact] = [
        StationFact(label: "Genres", value: "Jazz, R&B, Electronic, Downtempo"),
        StationFact(label: "Stream", value: "music.taliferro.com", url: URL(string: "https://music.taliferro.com/")),
        StationFact(label: "Based in", value: "Seattle, Washington, USA"),
        StationFact(label: "Operated by", value: "Taliferro Music"),
        StationFact(label: "Email", value: "info@taliferro.com", url: URL(string: "mailto:info@taliferro.com")),
        StationFact(label: "Phone", value: "401.646.2662", url: URL(string: "tel:+14016462662"))
    ]

    static let socialLinks: [SocialLink] = [
        SocialLink(label: "TuneIn", url: URL(string: "https://tunein.com/radio/Taliferro-Music-Radio-s358780/")!),
        SocialLink(label: "MegaRadio", url: URL(string: "https://themegaradio.com/en/station/taliferro-music-radio")!),
        SocialLink(label: "Streema", url: URL(string: "https://streema.com/radios/Taliferro_Music_Radio")!)
    ]
}

enum AboutTools {
    static let all: [AboutTool] = [
        AboutTool(
            name: "Find",
            description: "Type any company, topic, or question. Get one strong result — not a list of 30,000 links — with context pills to drill deeper.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/find-logo.png")!,
            ctaLabel: "Try Find",
            ctaURL: URL(string: "https://find.taliferro.com")!,
            caption: "No account required"
        ),
        AboutTool(
            name: "Email Signature Builder",
            description: "Build a branded email signature in under two minutes. Pick a layout, add your details, copy the HTML — done.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/outreach/email-signature-builder.png")!,
            ctaLabel: "Try it free",
            ctaURL: URL(string: "https://todd.taliferro.tech/email-signature-builder")!,
            caption: "No account required"
        ),
        AboutTool(
            name: "SayIt",
            description: "Social media built for organizations. Post what you need, find who can help, connect with people who get it.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/sayit/sayit-logo.png")!,
            ctaLabel: "Join SayIt",
            ctaURL: URL(string: "https://sayit.taliferro.tech")!,
            caption: "Free to join"
        ),
        AboutTool(
            name: "TODD",
            description: "Tell TODD what is stuck in your organization. Get a clear next move, the right place to start, or the fastest path forward.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/TODD-icon.png")!,
            ctaLabel: "Ask TODD now",
            ctaURL: URL(string: "https://todd.taliferro.com")!,
            caption: "Free guidance · No credit card"
        ),
        AboutTool(
            name: "Lead Vault",
            description: "Search millions of verified business contacts by industry, role, or location. Browse results at no cost — pay only when you unlock a lead you want.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/lead-vault/lead-vault.png")!,
            ctaLabel: "Search Lead Vault",
            ctaURL: URL(string: "https://todd.taliferro.tech/lead-vault")!,
            caption: "Search free · Pay per lead"
        ),
        AboutTool(
            name: "Meet Maya",
            description: "Get candid marketing advice from your on-call Marketing Director. She will help with message clarity, campaigns, audience focus, and what to fix first.",
            iconURL: URL(string: "https://todd.taliferro.tech/assets/marketing/marketing-director-avatar.png")!,
            ctaLabel: "Talk with Maya",
            ctaURL: URL(string: "https://todd.taliferro.tech/marketing-director")!,
            caption: "Free advice · Paid execution"
        )
    ]
}
