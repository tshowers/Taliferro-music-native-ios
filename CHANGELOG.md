# Changelog

All notable changes to this project are documented here.

## 1.2 (build 5) — 2026-10-26

1.1 was already approved, so App Store Connect closed it to new builds.

### Fixed
- Music keeps playing with the screen locked: `UIBackgroundModes` now lives
  in `TaliferroMusic/Support/Info.plist`, since it has no `INFOPLIST_KEY_`
  build setting.
- Pressing play after a pause rejoins the live stream instead of picking up
  ~2 minutes behind, so now playing matches what's heard.

### Added
- App Store rating prompt (`AppReview.swift`): after about 5 tracks that
  started while playing, the app asks for a rating with Apple's built-in
  prompt — only in the foreground, at most once per version; iOS itself caps
  it at 3 times a year and never shows it in TestFlight.
- Menu: "Rate Taliferro Music" opens the App Store review form any time.

## 1.1 (build 3) — 2026-10-01

Feature parity with the web player.

### Added
- Recently played replaces Featured on the main screen: the last 10 tracks on the current mood, with art, start time, and Apple Music/Spotify/Bandcamp links for featured artists. Refreshes when the track changes (`GET /recently-played/<channel>`).
- Listener count ("12 people are listening now") under the progress bar, station-wide, shown only at 8 or more (`GET /listeners`, polled every 30s).
- Sleep timer: stop after 15, 30, 45, or 60 minutes, with a countdown on the button and a ~6s fade-out. Keeps running with the screen locked via the existing background-audio mode.
- Menu sheet (header button) holding Featured artists and About, matching the web player's menu.

### Changed
- About moved from the footer into the menu.
- `project.yml` now carries `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`, the upside-down portrait orientation, and `xcodeVersion`, which had only been set in the checked-in Xcode project, so `xcodegen generate` no longer drops them.
- Remote-command and interruption handlers hop to the main actor before touching the player (1.0.1).

## 2026-08-29

### Added
- Extracted the native SwiftUI Taliferro Music Radio client from the `taliferrotech` monorepo into its own repo — a standalone iOS app (bundle ID `tech.taliferro.musicradio`) with a Radio player screen (view model, share sheet) and an About screen, backed by `AppConfig`/`RadioAPIClient`/`AudioPlayerService`.
- README documenting the project structure, XcodeGen-based project setup (`xcodegen generate`), and the ad-hoc export options workflow.
- README banner.

### Notes
- This app was never part of TODD's documented structure or CI — it plays the live HLS stream from the separately-hosted [radio engine backend](https://github.com/tshowers/Taliferro-music-radio-engine) and has a companion [web player](https://github.com/tshowers/taliferro-music-frontend) in its own repo too. No backend or CI changes were needed for this extraction.
- The old `ios/` folder was subsequently removed from the `taliferrotech` monorepo now that this app (and its sibling iOS apps) live in their own repos under `apps/ios/`.
