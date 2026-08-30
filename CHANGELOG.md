# Changelog

All notable changes to this project are documented here.

## 2026-08-29

### Added
- Extracted the native SwiftUI Taliferro Music Radio client from the `taliferrotech` monorepo into its own repo — a standalone iOS app (bundle ID `tech.taliferro.musicradio`) with a Radio player screen (view model, share sheet) and an About screen, backed by `AppConfig`/`RadioAPIClient`/`AudioPlayerService`.
- README documenting the project structure, XcodeGen-based project setup (`xcodegen generate`), and the ad-hoc export options workflow.
- README banner.

### Notes
- This app was never part of TODD's documented structure or CI — it plays the live HLS stream from the separately-hosted [radio engine backend](https://github.com/tshowers/Taliferro-music-radio-engine) and has a companion [web player](https://github.com/tshowers/taliferro-music-frontend) in its own repo too. No backend or CI changes were needed for this extraction.
- The old `ios/` folder was subsequently removed from the `taliferrotech` monorepo now that this app (and its sibling iOS apps) live in their own repos under `apps/ios/`.
