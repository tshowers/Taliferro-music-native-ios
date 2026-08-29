# Taliferro Music (iOS)

Native SwiftUI client for [Taliferro Music Radio](https://music.taliferro.com) —
plays the live HLS stream from the
[radio engine backend](https://github.com/tshowers/Taliferro-music-radio-engine).
Companion to the [web player](https://github.com/tshowers/taliferro-music-frontend).

## Structure

```
TaliferroMusic/
  App/            App entry point
  Features/
    Radio/        Player screen + view model
    About/        About screen
  Models/         Codable response models
  Services/       AppConfig, RadioAPIClient, AudioPlayerService
  Resources/      Asset catalog, privacy manifest
```

Bundle ID: `tech.taliferro.musicradio`.

## Setup

Project files are generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen)
from `project.yml`:

```bash
xcodegen generate
open TaliferroMusic.xcodeproj
```

For ad-hoc export builds, copy `ExportOptions-AdHoc.plist.example` to
`ExportOptions-AdHoc.plist` and fill in your own Apple Developer Team ID
(gitignored — kept local, not committed).
