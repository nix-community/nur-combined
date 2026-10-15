# NRS Internet Relay Client

Client for the Australian National Relay Service (NRS) Internet Relay (`https://nrschat.nrscall.gov.au/nrs/internetrelay`) built using Flutter and [Rinf](https://github.com/cunarist/rinf).

## Overview
- **Framework**: Flutter with Material 3 high-contrast accessible design.
- **Native Hub**: Rust actor system running asynchronously via Tokio and Rinf 8.11.0.
- **Relay Protocol**: Real session management, Australian area-code/state routing (`NSW`, `VIC`, `QLD`, `WA`, `SA`, `TAS`, `ACT`, `NT`), turn token tracking (`GA`, `GA TO SK`, `SK`, `SKSK`), and transcript export (`.txt`, `.json`).
- **Emergency Priority**: Quick dialer for Triple Zero (`000`), `112`, and `911` mapped to the `P_NRS_Emergency_InternetRelay_Chat` campaign.
- **Network & GeoIP**: Configurable Australian SOCKS5/HTTP proxy support with real-time GeoIP check.
- **API Documentation**: Detailed reverse-engineering and network endpoint documentation in [`docs/NRS_API_ENDPOINTS.md`](./docs/NRS_API_ENDPOINTS.md).
