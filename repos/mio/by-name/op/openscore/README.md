# OpenScore

Open-source MuseScore sheet music downloader (MIDI, MP3, PDF).

Download protocol adapted from [dl-librescore](https://github.com/LibreScore/dl-librescore) (MIT).

**Not affiliated with MuseScore, Ultimate Guitar, or LibreScore.**

## Features

- Search (DuckDuckGo `site:musescore.com`) or paste a MuseScore score URL
- Download MIDI, MP3, and multi-page PDF
- Local downloads list, theme, download folder, optional HTTP proxy

## Build

```bash
nix build .#openscore
```

Outside Nix:

```bash
flutter pub get
flutter run -d macos   # or linux / windows / android
```

## Proxy

MuseScore often sits behind Cloudflare. If requests fail, set a proxy URL under
Settings. Use `{url}` as a placeholder for the encoded target, or a prefix that
receives the URI-encoded URL.
