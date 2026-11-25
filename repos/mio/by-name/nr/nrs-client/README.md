# NRS and NZ Relay Client

Unofficial desktop client for the Australian National Relay Service (NRS) Internet Relay and New Zealand Relay (NZ Relay) text relay, built using Flutter and [Rinf](https://github.com/cunarist/rinf).

This project is not affiliated with or endorsed by the Australian Government, NRS, NZ Relay, MBIE, or Concentrix.

## Overview
- **Framework**: Flutter with Material 3 high-contrast accessible design.
- **Native Hub**: Rust actor system running asynchronously via Tokio and Rinf 8.11.0.
- **Authentication & Registration**: NRS account login and NZ Relay email login using the current dynamic `getAccountDetails` account key.
- **Relay Protocol**: Concentrix OmniChat session management (`omniChatService.asmx`), AU/NZ routing, turn token tracking (`GA`, `GA TO SK`, `SK`, `SKSK`), and transcript export (`.txt`, `.json`).
- **Emergency Guidance**: AU emergency calls use NRS. NZ prioritises direct 111, 111TXT or the Deaf Emergency TTY; NZ Relay cannot prioritise emergency calls and is available only as an explicitly warned last resort.
- **Network & GeoIP**: Configurable Australian SOCKS5/HTTP proxy support with real-time GeoIP check.
- **API Documentation**: Detailed reverse-engineering and network endpoint documentation in [`docs/NRS_API_ENDPOINTS.md`](./docs/NRS_API_ENDPOINTS.md).
