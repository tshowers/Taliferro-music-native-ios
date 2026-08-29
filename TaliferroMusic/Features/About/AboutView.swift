import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                aboutPanel
                stationFactsPanel
                findUsPanel
                toolsPanel
                footer
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Taliferro Music Radio")
                .font(.title2.bold())
                .foregroundStyle(Theme.text)
            Text("A 24/7 online radio station streaming jazz, R&B, and electronic music from Taliferro Music artists.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
        }
    }

    private var aboutPanel: some View {
        panel {
            panelTitle("About")
            Text("Taliferro Music Radio is an internet-only live stream operated by Taliferro Music. There is no broadcast license or terrestrial signal — you listen entirely through the stream at music.taliferro.com.")
                .font(.subheadline)
                .foregroundStyle(Theme.text)
            Text("The station rotates between a handful of moods (downtempo, jazzy, groove, and more) built from tracks by Taliferro Music's roster of artists.")
                .font(.subheadline)
                .foregroundStyle(Theme.text)
        }
    }

    private var stationFactsPanel: some View {
        panel {
            panelTitle("Station facts")
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(StationInfo.facts.enumerated()), id: \.element.id) { index, fact in
                    HStack(alignment: .top, spacing: 8) {
                        Text(fact.label)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.faint)
                            .frame(width: 92, alignment: .leading)
                        if let url = fact.url {
                            Link(fact.value, destination: url)
                                .font(.footnote)
                                .foregroundStyle(Theme.accent)
                        } else {
                            Text(fact.value)
                                .font(.footnote)
                                .foregroundStyle(Theme.text)
                        }
                    }
                    .padding(.vertical, 10)
                    if index < StationInfo.facts.count - 1 {
                        Divider().background(Theme.divider)
                    }
                }
            }
        }
    }

    private var findUsPanel: some View {
        panel {
            panelTitle("Find us on")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], alignment: .leading, spacing: 10) {
                ForEach(StationInfo.socialLinks) { link in
                    Link(link.label, destination: link.url)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().stroke(Theme.divider, lineWidth: 1))
                }
            }
        }
    }

    private var toolsPanel: some View {
        panel {
            panelTitle("More from Taliferro")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                ForEach(AboutTools.all) { tool in
                    toolCard(tool)
                }
            }
        }
    }

    private func toolCard(_ tool: AboutTool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: tool.iconURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 8).fill(Theme.surfaceAlt)
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(tool.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.text)
            Text(tool.description)
                .font(.caption)
                .foregroundStyle(Theme.muted)
            Spacer(minLength: 0)
            Link("\(tool.ctaLabel) \u{2192}", destination: tool.ctaURL)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            Text(tool.caption)
                .font(.caption2)
                .foregroundStyle(Theme.faint)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).stroke(Theme.divider, lineWidth: 1))
    }

    private var footer: some View {
        Text(verbatim: "© \(currentYear) Taliferro Music")
            .font(.caption2)
            .foregroundStyle(Theme.faint)
            .padding(.top, 4)
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
    }

    private func panelTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.faint)
    }
}
