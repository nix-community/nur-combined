# Australian National Relay Service (NRS) API & Endpoints Architecture

This document details how the network endpoints, protocols, and payloads for the National Relay Service (NRS) Internet Relay (`https://nrschat.nrscall.gov.au/nrs/internetrelay`) were analyzed, identified, and integrated.

---

## 1. Network Topology & DNS Resolution

The official NRS Chat portal resides at:
- **Primary Domain**: `nrschat.nrscall.gov.au`
- **DNS CNAME**: `nrsappgw.concentrix.com`
- **IP Address**: `49.255.65.90` (Hosted by Concentrix Australia Pty Ltd, AS133481)
- **Service Operator**: Concentrix is the contracted operator delivering the National Relay Service under contract with the Australian Government Department of Infrastructure, Transport, Regional Development, Communications and the Arts (DOCA).

### DNS Verification:
```bash
$ host nrschat.nrscall.gov.au
nrschat.nrscall.gov.au is an alias for nrsappgw.concentrix.com.
nrsappgw.concentrix.com has address 49.255.65.90
```

---

## 2. GeoIP Enforcement & Handshake Inspection

The gateway at `nrsappgw.concentrix.com` enforces strict Australian-only IP geo-blocking at the Apache reverse-proxy layer:

- **Inside Australia / Australian Proxy**:
  - `GET /nrs/internetrelay` returns `HTTP 200 OK` with session cookies (`JSESSIONID`, etc.).
- **Outside Australia (Foreign IP)**:
  - Returns `HTTP 302 Found`:
    ```http
    HTTP/1.1 302 Found
    Server: Apache
    Location: https://nrsinfo.nrscall.gov.au/geoinfo.html
    ```
  - `geoinfo.html` explicitly states:
    > *"The National Relay Service cannot be used to make calls from foreign points to points within Australia. Because your IP address has been identified as one originating from somewhere outside of Australia, your call will not be completed."*

Because Apache checks the TCP connection source IP at the transport level, `X-Forwarded-For` spoofing is rejected. Authentic communication from outside Australia requires routing through an Australian proxy (`SOCKS5` or `HTTP`) or an Australian VPN exit node.

---

## 3. Web Client Asset Discovery & Reverse Engineering

By inspecting archived JavaScript assets (`/nrs/assets/js/main.js`, `cookies.js`, and WebCompat telemetry from issue [#72157](https://github.com/webcompat/web-bugs/issues/72157)), the underlying contact center framework was identified as **Enghouse Interactive / Genesys G2C (`MyG2C.API`)**.

### Discovered Campaign Names (`txtCampaignName`):
1. **`P_NRS_Internet_MakeACall_Chat`**: Standard Internet Relay call placement.
2. **`P_NRS_Emergency_InternetRelay_Chat`**: Priority Triple Zero (000), 112, or 911 emergency relay call.
3. **`P_NRS_InternetRelayReceiveACall_Chat`**: Inbound Internet Relay calls.
4. **`P_NRS_Captioned_MakeACall_Chat`**: NRS Captioned relay call placement.
5. **`P_NRS_CaptionedRelay_Chat`**: Standard captioned relay.

### Core Data Fields (`MyG2C.API.setData`):
| Field | Type | Description |
|---|---|---|
| `txtOPNumber` | String | The target telephone number to dial (e.g. `0412345678` or `000`) |
| `txtNRSNumber` | String | The caller's registered NRS profile phone number |
| `txtCampaignName` | String | Campaign identifier (see above) |
| `txtState` | String | Australian state/territory abbreviation (`NSW`, `VIC`, `QLD`, `WA`, `SA`, `TAS`, `ACT`, `NT`) |
| `txtIPAddress` | String | Caller's detected public IP address |
| `chatMsg` | String | Initial session text (e.g., `"You are using NRS Chat"` or `"Emergency internet relay chat"`) |
| `callNotes` | String | Optional instruction passed to the Relay Officer |

### Original Frontend Invocation:
```javascript
// Emergency Initiation:
MyG2C.API.setData([
    { id: 'txtOPNumber', value: '000' },
    { id: 'txtNRSNumber', value: userNrsNumber },
    { id: 'txtIPAddress', value: ipAddress },
    { id: 'txtCampaignName', value: 'P_NRS_Emergency_InternetRelay_Chat' }
]);
MyG2C.API.chatAsk('Emergency internet relay chat');

// Standard Make-a-Call Initiation:
MyG2C.API.setData([
    { id: 'txtOPNumber', value: targetPhoneNumber },
    { id: 'txtNRSNumber', value: userNrsNumber },
    { id: 'txtIPAddress', value: ipAddress },
    { id: 'txtCampaignName', value: 'P_NRS_Internet_MakeACall_Chat' },
    { id: 'txtState', value: selectedState }
]);
MyG2C.API.chatAsk('You are using NRS Chat');
```

---

## 4. Client Implementation Mapping

In `nrs-client`, this API structure is implemented in Rust (`native/hub/src/actors/call_actor.rs` and `geo_actor.rs`) using `reqwest`:

1. **Proxy & Cookie Jar Support**:
   - Built with `.cookie_store(true)` to preserve session tokens throughout the relay conversation.
   - Accepts user-configured Australian proxy URLs (`socks5://...`, `http://...`).
2. **State Selection & Presets**:
   - Exposes Australian state/territory dropdown and common presets (`000`, `1800 555 660`, `131 444`, `1800 022 222`).
3. **Turn-Taking Standards**:
   - Adheres to Australian relay conventions (`GA` = Go Ahead, `GA to SK` = Ready to Hang Up, `SK` = Stop Keying / Hanging Up, `SKSK` = Call Terminated).
