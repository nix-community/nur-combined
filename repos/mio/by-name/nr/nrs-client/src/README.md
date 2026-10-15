# NRS Internet Relay Client

A cross-platform National Relay Service (NRS) Internet Relay client for Australia (`https://nrschat.nrscall.gov.au/nrs/internetrelay`), built with [Flutter](https://flutter.dev) and [Rinf](https://github.com/cunarist/rinf) (Rust native logic).

---

## 🎯 Features

- **Standard NRS Internet Relay Support**: Connects to the Australian National Relay Service to place calls via a text Relay Officer (RO).
- **Relay Turn-Taking UI**:
  - Auto-appends **`GA`** (*Go Ahead*) to messages by default as required by relay conventions.
  - Quick action buttons for **`GA`**, **`GA to SK`** (*Ready to wrap up*), **`SK`** (*Stop Keying / Goodbye*), and **`SKSK`** (*Terminate call*).
  - Quick phrases: *Please repeat*, *Please spell that*, *Hold / Resume*.
- **Emergency Priority (Triple Zero `000`)**:
  - One-tap priority access to emergency services (Police, Fire, Ambulance) via NRS.
- **Australian Presets**:
  - Built-in numbers for NRS Helpdesk (`1800 555 660`), Police Non-Emergency (`131 444`), and healthdirect (`1800 022 222`).
- **GeoIP & Proxy Bypass**:
  - `nrschat.nrscall.gov.au` restricts access to Australian IP addresses (redirecting non-AU IPs to `geoinfo.html`).
  - The client includes built-in SOCKS5 and HTTP proxy support (`reqwest` with proxy integration) and a one-click GeoIP connection tester.
- **Simulator / Test Mode**:
  - A local Relay Officer simulation engine that emulates the complete call flow (queueing, RO assignment, dialing, ringing, answered party speech, and turn-taking) for testing outside Australia.
- **Transcript Export**:
  - Export chat transcripts to formatted `.txt` or `.json` with one click.

---

## 🏗️ Architecture

```
Flutter Frontend (Dart)
  ├── DialScreen        (Keypad, presets, emergency 000, call notes)
  ├── ChatScreen        (Turn-taking UI, message bubbles, transcript)
  └── SettingsDialog    (Proxy config, GeoIP tester, Simulator mode)
         ▲
         │  Rinf Signals (Bincode / Rust FFI)
         ▼
Rust Backend (`native/hub`)
  ├── CallActor         (Session management, timing, turn tokens, simulation)
  ├── GeoActor          (GeoIP verification & proxy checking)
  └── NRS Transport     (reqwest HTTP/SOCKS5 client)
```

---

## 🚀 Getting Started

### Using Nix (Flake Dev Shell)

Enter the development environment with all required tools (Flutter, Cargo, Rust, Protobuf, GTK3):

```bash
nix develop
```

### Running the App

```bash
# Run on Linux Desktop
flutter run -d linux

# Run on Web (Chrome)
flutter run -d chrome
```

### Code Generation with Rinf

If you modify structs in `native/hub/src/signals/mod.rs`:

```bash
rinf gen
```

---

## 🧪 Testing

Run both Flutter and Rust test suites:

```bash
# Flutter widget & UI tests
flutter test

# Rust backend tests
cd native/hub && cargo test
```
