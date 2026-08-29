import SwiftUI
import UIKit

// Mirrors the web player's CSS custom properties (index.html / about.html),
// which swap between a dark and light token set based on prefers-color-scheme.
// Each Color here adapts live to the system appearance the same way.
enum Theme {
    static let background = adaptive(
        dark: UIColor(red: 0.039, green: 0.043, blue: 0.059, alpha: 1),   // #0a0b0f
        light: UIColor(red: 0.965, green: 0.969, blue: 0.976, alpha: 1)   // #f6f7f9
    )

    static let surface = adaptive(
        dark: UIColor(red: 0.067, green: 0.075, blue: 0.098, alpha: 1),   // #111319
        light: .white
    )

    static let surfaceAlt = adaptive(
        dark: UIColor(red: 0.090, green: 0.102, blue: 0.133, alpha: 1),   // #171a22
        light: UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1)   // #f3f4f6
    )

    static let accent = adaptive(
        dark: UIColor(red: 0.310, green: 0.878, blue: 0.784, alpha: 1),   // #4fe0c8
        light: UIColor(red: 0.059, green: 0.612, blue: 0.522, alpha: 1)   // #0f9c85
    )

    // Text/icon color drawn on top of an accent-filled background.
    static let accentInk = adaptive(
        dark: UIColor(red: 0.016, green: 0.129, blue: 0.110, alpha: 1),   // #04211c
        light: .white
    )

    static let text = tinted(darkAlpha: 0.94, lightAlpha: 0.94)
    static let muted = tinted(darkAlpha: 0.52, lightAlpha: 0.54)
    static let faint = tinted(darkAlpha: 0.34, lightAlpha: 0.38)
    static let divider = tinted(darkAlpha: 0.08, lightAlpha: 0.09)

    private static let lightTextBase = UIColor(red: 0.059, green: 0.071, blue: 0.098, alpha: 1) // #0f1219

    private static func adaptive(dark: UIColor, light: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    // Dark mode tints are translucent white over the dark background; light
    // mode tints are translucent near-black over the light background —
    // same technique the web CSS variables use.
    private static func tinted(darkAlpha: CGFloat, lightAlpha: CGFloat) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(darkAlpha)
                : lightTextBase.withAlphaComponent(lightAlpha)
        })
    }
}
