# NRS and NZ Relay Client

A cross-platform National Relay Service (NRS) Internet Relay and New Zealand Relay text-relay client, built with [Flutter](https://flutter.dev) and [Rinf](https://github.com/cunarist/rinf) (Rust native logic).

This is an unofficial client and is not affiliated with NRS, NZ Relay, the Australian Government, MBIE, or Concentrix.

---

## 🎯 Features

- **NRS and NZ Relay Text Calling**: Connects to the selected relay provider to place calls via a text Relay Officer.
- **Relay Turn-Taking UI**:
  - Auto-appends **`GA`** (*Go Ahead*) to messages by default as required by relay conventions.
  - Quick action buttons for **`GA`**, **`GA to SK`** (*Ready to wrap up*), **`SK`** (*Stop Keying / Goodbye*), and **`SKSK`** (*Terminate call*).
  - Quick phrases: *Please repeat*, *Please spell that*, *Hold / Resume*.
- **Emergency Guidance**:
  - Australian emergency calls can use NRS.
  - NZ users are directed to 111, 111TXT, or the Deaf Emergency TTY first. NZ Relay does not prioritise emergency calls.
- **Australian Presets**:
  - Built-in numbers for NRS Helpdesk (`1800 555 660`), Police Non-Emergency (`131 444`), and healthdirect (`1800 022 222`).
- **GeoIP & Proxy Support**:
  - `nrschat.nrscall.gov.au` restricts access to Australian IP addresses (redirecting non-AU IPs to `geoinfo.html`).
  - The client includes built-in SOCKS5 and HTTP proxy support (`reqwest` with proxy integration) and a one-click GeoIP connection tester.
- **Transcript Export**:
  - Export chat transcripts to formatted `.txt` or `.json` with one click.

---

## 🏗️ Architecture

```
Flutter Frontend (Dart)
  ├── DialScreen        (Keypad, presets, regional emergency guidance, call notes)
  ├── ChatScreen        (Turn-taking UI, message bubbles, transcript)
  └── SettingsDialog    (Proxy config and gateway reachability check)
         ▲
         │  Rinf Signals (Bincode / Rust FFI)
         ▼
Rust Backend (`native/hub`)
  ├── CallActor         (Session management, timing and turn tokens)
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
