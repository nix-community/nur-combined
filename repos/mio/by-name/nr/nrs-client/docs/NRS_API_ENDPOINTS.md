# Australian National Relay Service (NRS) API & Endpoints Architecture

This document details how the network endpoints, protocols, and payloads for the National Relay Service (NRS) Internet Relay (`https://nrschat.nrscall.gov.au/nrs/internetrelay`) and Concentrix OmniChat service are structured and integrated into `nrs-client`.

---

## 1. Network Topology & Service Operator

The official NRS Chat portal resides at:
- **Primary Domain**: `nrschat.nrscall.gov.au`
- **DNS CNAME**: `nrsappgw.concentrix.com`
- **IP Address**: `49.255.65.90` (Hosted by Concentrix Australia Pty Ltd, AS133481)
- **Service Operator**: Concentrix delivers the National Relay Service under contract with the Australian Government Department of Infrastructure, Transport, Regional Development, Communications and the Arts (DOCA).
- **OmniChat Gateway**: `https://omnicustomwebsyd.concentrix.com/NRS/NRSOMNIShell/Prod/omniChatService.asmx`

---

## 2. GeoIP Enforcement

The gateway at `nrsappgw.concentrix.com` enforces Australian IP geo-blocking at the Apache reverse-proxy layer:

- **Inside Australia / Australian Proxy**:
  - `GET /nrs/internetrelay` returns `HTTP 200 OK`.
- **Outside Australia (Foreign IP)**:
  - Redirects (`HTTP 302`) to `https://nrsinfo.nrscall.gov.au/geoinfo.html`:
    > *"The National Relay Service cannot be used to make calls from foreign points to points within Australia. Because your IP address has been identified as one originating from somewhere outside of Australia, your call will not be completed."*

Authentic communication from outside Australia requires routing through an Australian proxy (`SOCKS5` or `HTTP`) or an Australian VPN exit node.

---

## 3. Mandatory User Registration & Authentication (Since April 2021)

Effective **April 20, 2021**, registration and login became **mandatory** for all standard NRS calls (Internet Relay, Captions, Video Relay). **Emergency calls (Triple Zero `000`, `112`, `911`) remain exempt.**

### Login Endpoint:
- **URL**: `POST https://nrschat.nrscall.gov.au/nrsapi/services/rest/user/login`
- **Headers**: `Content-Type: application/json`
- **Payload**:
  ```json
  {
    "userName": "0412345678",
    "password": "{ENC}<base64_encoded_password>",
    "loginType": "4",
    "duplicateRequest": "false",
    "requestIdentificationNumber": 1729050000000,
    "deviceData": {
      "appName": "NRS",
      "appVersion": "1.0",
      "browserVersion": "128.0",
      "browser": "Firefox",
      "osType": "Mac",
      "osVersion": "15.0"
    }
  }
  ```

### Response Schema:
- **Success (`status: 0`)**:
  ```json
  {
    "status": 0,
    "userContractBean": {
      "id": "TOKEN_OR_USER_ID",
      "firstName": "John",
      "lastName": "Doe",
      "mobileNo": "0412345678",
      "email": "user@example.com",
      "nrsId": "NRS-12345",
      "userType": 1
    }
  }
  ```
- **Error (`status != 0`)**:
  ```json
  {
    "status": 1,
    "keyValuePairs": [
      { "key": "ERROR_CODE", "value": "2073" },
      { "key": "ERROR_MSG", "value": "Incorrect username or password" }
    ]
  }
  ```

---

## 4. Concentrix OmniChat Protocol (`omniChatService.asmx`)

The live chat session with the Relay Officer is managed through Concentrix's OmniChat Web Services:

- **Client Key**: `123@TAPAC$$DevInt`
- **Base Endpoint**: `https://omnicustomwebsyd.concentrix.com/NRS/NRSOMNIShell/Prod/omniChatService.asmx`

### Call Flow:
1. **Public IP Discovery**:
   - `POST https://nrschat.nrscall.gov.au/nrsapi/services/rest/user/getMyIp`
   - Returns detected caller public IP.
2. **Session Setup (`Datafatching`)**:
   - `GET https://omnicustomwebsyd.concentrix.com/NRS/NRSCHATUI/PROD/Datafatching/Datafatching?NRSUserId={token}&Campaign={campaign}&OPNumber={recipient}&NRSNumber={caller}&IPAddress={ip}&State={state}`
   - Sets up server-side session and cookie (`ASP.NET_SessionId`).
3. **Session Allocation (`GetSessionId`)**:
   - `GET /GetSessionId`
   - Returns: `[{"sessionvalue": "..."}]`
4. **Chat Initiation (`InitiateChat`)**:
   - `GET /InitiateChat?ClientKey=123@TAPAC$$DevInt&CampaignKey={campaign}&GMTOffset=0&OperatingSystem=mac&Language=en&txtNRSNumber={caller}&txtOPNumber={recipient}&txtCampaignName={campaign}&txtIPAddress={ip}&txtEmailID=&sessionid={session_id}&txtState={state}`
   - Returns either queue waiting messages (`-6` or `-5`) or assigned agent info:
     `[{"SessionId": "...", "ChatRoomId": "...", "AgentName": "...", "Status": "...", "pagehisto": 0}]`
5. **Message Polling (`GetNewMessages`)**:
   - `GET /GetNewMessages?SessionId={session_id}&ChatRoomId={chat_room_id}&ClientKey=123@TAPAC$$DevInt&CampaignKey={campaign}&pagehisto={page_histo}`
   - Polls every ~1.5s for incoming officer speech.
6. **Message Dispatch (`SendMessage`)**:
   - `GET /SendMessage?SessionId={session_id}&ChatRoomId={chat_room_id}&Message={encoded_text}&ClientKey=123@TAPAC$$DevInt&CampaignKey={campaign}&pagehisto={page_histo}`
7. **Session Termination (`EndChat`)**:
   - `GET /EndChat?SessionId={session_id}`

---

## 5. Campaign Mapping

| Campaign Name | Call Type | Authentication |
|---|---|---|
| `P_NRS_Internet_MakeACall_Chat` | Standard Internet Relay Call | **Mandatory** (`NRSUserId` required) |
| `P_NRS_Emergency_InternetChat_Make_a_call_Chat` | Emergency Triple Zero (`000`), `112`, `911` | **Exempt** (no login required) |
| `P_NRS_Helpdesk_Chat_Web` | NRS Helpdesk Inquiries | Optional |
