use crate::actors::auth_actor::AuthActor;
use crate::signals::{
    CallStateSignal, ConnectCallRequest, DisconnectCallRequest, ExportTranscriptRequest,
    QuickActionRequest, RelayMessageSignal, SendRelayMessageRequest, TranscriptExportedSignal,
};
use chrono::Local;
use rinf::{DartSignal, RustSignal};
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;
use tokio::{spawn, time::sleep};

const CLIENT_KEY: &str = "123@TAPAC$$DevInt";
const AU_OMNI_SHELL_BASE: &str = "https://omnicustomwebsyd.concentrix.com/NRS/NRSOMNIShell/Prod/omniChatService.asmx";
const NZ_OMNI_SHELL_BASE: &str = "https://omnicustomwebauc.concentrix.com/NZRelay/omnishell/prod/omniChatService.asmx";

#[derive(Clone)]
struct StoredMessage {
    timestamp: String,
    sender: String,
    content: String,
}

#[derive(Clone, Default)]
struct ConcentrixSession {
    session_id: String,
    chat_room_id: String,
    campaign_key: String,
    omni_shell_base: String,
    page_histo: u64,
}

pub struct CallActor {
    active_call: Arc<AtomicBool>,
    call_duration: Arc<AtomicU64>,
    messages: Arc<Mutex<Vec<StoredMessage>>>,
    http_client: Arc<Mutex<Option<reqwest::Client>>>,
    session: Arc<Mutex<Option<ConcentrixSession>>>,
    current_country: Arc<Mutex<String>>,
}

impl CallActor {
    pub fn start() {
        let active_call = Arc::new(AtomicBool::new(false));
        let call_duration = Arc::new(AtomicU64::new(0));
        let messages = Arc::new(Mutex::new(Vec::new()));
        let http_client = Arc::new(Mutex::new(None));
        let session = Arc::new(Mutex::new(None));
        let current_country = Arc::new(Mutex::new("AU".to_string()));

        let actor = Arc::new(Self {
            active_call: active_call.clone(),
            call_duration: call_duration.clone(),
            messages: messages.clone(),
            http_client: http_client.clone(),
            session: session.clone(),
            current_country: current_country.clone(),
        });

        // 1. Listen for Connect Call requests
        {
            let actor_clone = actor.clone();
            spawn(async move {
                let receiver = ConnectCallRequest::get_dart_signal_receiver();
                while let Some(pack) = receiver.recv().await {
                    let req = pack.message;
                    actor_clone.handle_connect(req).await;
                }
            });
        }

        // 2. Listen for Send Message requests
        {
            let actor_clone = actor.clone();
            spawn(async move {
                let receiver = SendRelayMessageRequest::get_dart_signal_receiver();
                while let Some(pack) = receiver.recv().await {
                    let req = pack.message;
                    actor_clone.handle_send_message(req).await;
                }
            });
        }

        // 3. Listen for Quick Action requests
        {
            let actor_clone = actor.clone();
            spawn(async move {
                let receiver = QuickActionRequest::get_dart_signal_receiver();
                while let Some(pack) = receiver.recv().await {
                    let req = pack.message;
                    actor_clone.handle_quick_action(req).await;
                }
            });
        }

        // 4. Listen for Disconnect Call requests
        {
            let actor_clone = actor.clone();
            spawn(async move {
                let receiver = DisconnectCallRequest::get_dart_signal_receiver();
                while let Some(pack) = receiver.recv().await {
                    let req = pack.message;
                    actor_clone.handle_disconnect(req.reason).await;
                }
            });
        }

        // 5. Listen for Export Transcript requests
        {
            let actor_clone = actor.clone();
            spawn(async move {
                let receiver = ExportTranscriptRequest::get_dart_signal_receiver();
                while let Some(pack) = receiver.recv().await {
                    let req = pack.message;
                    actor_clone.handle_export(req.format).await;
                }
            });
        }
    }

    async fn record_and_emit_message(&self, sender: &str, content: &str) {
        let now = Local::now().format("%H:%M:%S").to_string();
        let trimmed = content.trim();
        let has_ga = trimmed.ends_with("GA")
            || trimmed.ends_with("ga")
            || trimmed.ends_with("GA TO SK")
            || trimmed.ends_with("SK")
            || trimmed.ends_with("SKSK");

        let msg_id = format!("msg_{}", Local::now().timestamp_millis());

        {
            let mut msgs = self.messages.lock().await;
            msgs.push(StoredMessage {
                timestamp: now.clone(),
                sender: sender.to_string(),
                content: content.to_string(),
            });
        }

        RelayMessageSignal {
            id: msg_id,
            timestamp: now,
            sender: sender.to_string(),
            content: content.to_string(),
            has_ga,
        }
        .send_signal_to_dart();
    }

    async fn handle_connect(&self, req: ConnectCallRequest) {
        self.active_call.store(true, Ordering::SeqCst);
        self.call_duration.store(0, Ordering::SeqCst);
        {
            let mut msgs = self.messages.lock().await;
            msgs.clear();
        }
        {
            let mut s = self.session.lock().await;
            *s = None;
        }

        let is_nz = req.country.as_deref().map(|c| c.eq_ignore_ascii_case("NZ")).unwrap_or(false);
        {
            let mut c = self.current_country.lock().await;
            *c = if is_nz { "NZ".to_string() } else { "AU".to_string() };
        }

        let is_emergency = if is_nz {
            req.recipient_phone == "111" || req.recipient_phone == "112" || req.recipient_phone == "911"
        } else {
            req.recipient_phone == "000" || req.recipient_phone == "112" || req.recipient_phone == "911"
        };

        CallStateSignal {
            state: "connecting".to_string(),
            status_message: if is_emergency {
                if is_nz {
                    "Initiating Priority Emergency Connection to 111...".to_string()
                } else {
                    "Initiating Priority Emergency Connection to Triple Zero (000)...".to_string()
                }
            } else if is_nz {
                "Connecting to New Zealand Relay Service (NZ Relay)...".to_string()
            } else {
                "Connecting to Australian National Relay Service...".to_string()
            },
            officer_badge: "".to_string(),
            recipient_number: req.recipient_phone.clone(),
            duration_seconds: 0,
            error_detail: None,
        }
        .send_signal_to_dart();

        let recipient_number = req.recipient_phone.clone();
        let active_flag = self.active_call.clone();
        let duration_counter = self.call_duration.clone();
        let actor_for_session = Arc::new(self.clone());

        // Spawn call duration timer task
        {
            let active = active_flag.clone();
            let duration = duration_counter.clone();
            let num = recipient_number.clone();
            spawn(async move {
                while active.load(Ordering::SeqCst) {
                    sleep(Duration::from_secs(1)).await;
                    if !active.load(Ordering::SeqCst) {
                        break;
                    }
                    let secs = duration.fetch_add(1, Ordering::SeqCst) + 1;
                    if secs % 2 == 0 {
                        CallStateSignal {
                            state: "connected".to_string(),
                            status_message: "Call in progress".to_string(),
                            officer_badge: "".to_string(),
                            recipient_number: num.clone(),
                            duration_seconds: secs,
                            error_detail: None,
                        }
                        .send_signal_to_dart();
                    }
                }
            });
        }

        // Run live Concentrix session (AU NRS or NZ Relay)
        spawn(async move {
            actor_for_session.run_live_nrs_session(req).await;
        });
    }

    async fn run_live_nrs_session(&self, req: ConnectCallRequest) {
        let is_nz = req.country.as_deref().map(|c| c.eq_ignore_ascii_case("NZ")).unwrap_or(false);
        let is_emergency = if is_nz {
            req.recipient_phone == "111" || req.recipient_phone == "112" || req.recipient_phone == "911"
        } else {
            req.recipient_phone == "000" || req.recipient_phone == "112" || req.recipient_phone == "911"
        };

        // Step 1: Resolve Authentication Token
        let user_token = if is_emergency {
            String::new()
        } else if is_nz {
            if let Some(ref token) = req.user_token {
                if !token.trim().is_empty() {
                    token.trim().to_string()
                } else if let Some(ref pwd) = req.password {
                    self.record_and_emit_message("system", "Authenticating with NZ Relay Credentials...").await;
                    match AuthActor::authenticate(&req.caller_phone, pwd, req.proxy_url.as_deref(), Some("NZ")).await {
                        Ok((tok, first_name, _, _)) => {
                            self.record_and_emit_message("system", &format!("Authentication successful for {}.", first_name)).await;
                            tok
                        }
                        Err(err) => {
                            self.handle_error(&format!("Authentication failed: {}", err), &req.recipient_phone).await;
                            return;
                        }
                    }
                } else {
                    String::new()
                }
            } else if let Some(ref pwd) = req.password {
                self.record_and_emit_message("system", "Authenticating with NZ Relay Credentials...").await;
                match AuthActor::authenticate(&req.caller_phone, pwd, req.proxy_url.as_deref(), Some("NZ")).await {
                    Ok((tok, first_name, _, _)) => {
                        self.record_and_emit_message("system", &format!("Authentication successful for {}.", first_name)).await;
                        tok
                    }
                    Err(err) => {
                        self.handle_error(&format!("Authentication failed: {}", err), &req.recipient_phone).await;
                        return;
                    }
                }
            } else {
                String::new()
            }
        } else if let Some(ref token) = req.user_token {
            if !token.trim().is_empty() {
                token.trim().to_string()
            } else if let Some(ref pwd) = req.password {
                self.record_and_emit_message("system", "Authenticating with NRS User Credentials...").await;
                match AuthActor::authenticate(&req.caller_phone, pwd, req.proxy_url.as_deref(), Some("AU")).await {
                    Ok((tok, first_name, _, _)) => {
                        self.record_and_emit_message("system", &format!("Authentication successful for {}.", first_name)).await;
                        tok
                    }
                    Err(err) => {
                        self.handle_error(&format!("Authentication failed: {}", err), &req.recipient_phone).await;
                        return;
                    }
                }
            } else {
                self.handle_error(
                    "NRS user registration and login are mandatory for standard calls since April 2021. Please log in first.",
                    &req.recipient_phone,
                )
                .await;
                return;
            }
        } else if let Some(ref pwd) = req.password {
            self.record_and_emit_message("system", "Authenticating with NRS User Credentials...").await;
            match AuthActor::authenticate(&req.caller_phone, pwd, req.proxy_url.as_deref(), Some("AU")).await {
                Ok((tok, first_name, _, _)) => {
                    self.record_and_emit_message("system", &format!("Authentication successful for {}.", first_name)).await;
                    tok
                }
                Err(err) => {
                    self.handle_error(&format!("Authentication failed: {}", err), &req.recipient_phone).await;
                    return;
                }
            }
        } else {
            self.handle_error(
                "NRS user registration and login are mandatory for standard calls since April 2021. Please log in first.",
                &req.recipient_phone,
            )
            .await;
            return;
        };

        // Step 2: Build HTTP client with cookie store
        let mut client_builder = reqwest::Client::builder()
            .timeout(Duration::from_secs(20))
            .cookie_store(true);

        if let Some(ref proxy) = req.proxy_url {
            if !proxy.trim().is_empty() {
                if let Ok(p) = reqwest::Proxy::all(proxy) {
                    client_builder = client_builder.proxy(p);
                }
            }
        }

        let client = match client_builder.build() {
            Ok(c) => c,
            Err(e) => {
                self.handle_error(&format!("Failed to build HTTP client: {}", e), &req.recipient_phone).await;
                return;
            }
        };

        {
            let mut guard = self.http_client.lock().await;
            *guard = Some(client.clone());
        }

        let omni_shell_base = if is_nz {
            NZ_OMNI_SHELL_BASE
        } else {
            AU_OMNI_SHELL_BASE
        };

        let campaign = if is_nz {
            "Text Relay"
        } else if is_emergency {
            "P_NRS_Emergency_InternetChat_Make_a_call_Chat"
        } else {
            "P_NRS_Internet_MakeACall_Chat"
        };

        if is_nz {
            self.record_and_emit_message("system", "Checking New Zealand gateway connection & IP routing...").await;
        } else {
            self.record_and_emit_message("system", "Checking Australian gateway connection & IP routing...").await;
        }

        // Step 3: Check GeoIP and get detected IP
        let now_ms = chrono::Local::now().timestamp_millis();
        let app_name = if is_nz { "TRS" } else { "NRS" };
        let my_ip_payload = serde_json::json!({
            "deviceData": {
                "appName": app_name,
                "appVersion": "1.0",
                "browserVersion": "128.0",
                "browser": "Firefox",
                "osType": "Mac",
                "osVersion": "15.0"
            },
            "duplicateRequest": "false",
            "requestGateway": "2",
            "requestIdentificationNumber": now_ms
        });

        let mut caller_ip = "127.0.0.1".to_string();
        let my_ip_url = if is_nz {
            "https://www.nzrelay.co.nz/trsapi/services/rest/user/getMyIp"
        } else {
            "https://nrschat.nrscall.gov.au/nrsapi/services/rest/user/getMyIp"
        };

        let mut ip_req = client
            .post(my_ip_url)
            .header("Content-Type", "application/json")
            .header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0");

        if is_nz {
            ip_req = ip_req.header("Authorization", "Basic dHJzYXBpOlRyNUwxdjNAMjAyMQ==");
        }

        if let Ok(ip_resp) = ip_req.json(&my_ip_payload).send().await {
            if let Ok(ip_val) = ip_resp.json::<serde_json::Value>().await {
                if let Some(ip) = ip_val.get("ipAddress").and_then(|i| i.as_str()) {
                    caller_ip = ip.to_string();
                }
            }
        }

        self.record_and_emit_message("system", &format!("Detected Caller IP: {}", caller_ip)).await;

        // Step 4: Contact Concentrix session setup (Datafatching)
        let setup_url = if is_nz {
            format!(
                "https://omnicustomwebauc.concentrix.com/NZRelay/chatui/prod/Datafatching/Datafatching?TRSUserId={}&Campaign=Text%20Relay&OPNumber={}&TRSNumber={}&IPAddress={}&InitialMessage={}",
                user_token, req.recipient_phone, req.caller_phone, caller_ip, Self::url_encode(&req.call_notes)
            )
        } else {
            format!(
                "https://omnicustomwebsyd.concentrix.com/NRS/NRSCHATUI/PROD/Datafatching/Datafatching?NRSUserId={}&Campaign={}&OPNumber={}&NRSNumber={}&IPAddress={}&State={}",
                user_token, campaign, req.recipient_phone, req.caller_phone, caller_ip, req.australian_state
            )
        };

        let datafatching_res = client
            .get(&setup_url)
            .header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0")
            .send()
            .await;

        if let Err(e) = datafatching_res {
            self.handle_error(&format!("Concentrix gateway handshake failed: {}", e), &req.recipient_phone).await;
            return;
        }

        // Step 5: Obtain Session ID from OmniShell
        let session_id_url = format!("{}/GetSessionId", omni_shell_base);
        let session_resp = match client.get(&session_id_url).send().await {
            Ok(r) => r,
            Err(e) => {
                self.handle_error(&format!("Failed to retrieve OmniChat session: {}", e), &req.recipient_phone).await;
                return;
            }
        };

        let session_text = match session_resp.text().await {
            Ok(t) => t,
            Err(e) => {
                self.handle_error(&format!("Failed to parse session ID response: {}", e), &req.recipient_phone).await;
                return;
            }
        };

        let session_id = match serde_json::from_str::<serde_json::Value>(&session_text) {
            Ok(val) => {
                val.as_array()
                    .and_then(|arr| arr.first())
                    .and_then(|obj| obj.get("sessionvalue"))
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string()
            }
            Err(_) => "".to_string(),
        };

        if session_id.is_empty() {
            self.handle_error("Unable to obtain a valid Concentrix relay session ID", &req.recipient_phone).await;
            return;
        }

        self.record_and_emit_message("system", &format!("Session allocated (ID: {}). Contacting Relay Officer queue...", session_id)).await;

        // Step 6: Initiate Chat
        let initiate_url = if is_nz {
            format!(
                "{}/InitiateChat?ClientKey={}&CampaignKey={}&GMTOffset=0&OperatingSystem=mac&Language=en&txtInboundNumber={}&txtOPNumber={}&txtCampaignName={}&txtIPAddress={}&txtEmailID=&SessionId={}",
                omni_shell_base, CLIENT_KEY, campaign, req.caller_phone, req.recipient_phone, campaign, caller_ip, session_id
            )
        } else {
            format!(
                "{}/InitiateChat?ClientKey={}&CampaignKey={}&GMTOffset=0&OperatingSystem=mac&Language=en&txtNRSNumber={}&txtOPNumber={}&txtCampaignName={}&txtIPAddress={}&txtEmailID=&sessionid={}&txtState={}",
                omni_shell_base, CLIENT_KEY, campaign, req.caller_phone, req.recipient_phone, campaign, caller_ip, session_id, req.australian_state
            )
        };

        let mut chat_room_id = String::new();
        let mut agent_name = "Relay Officer".to_string();
        let mut page_histo: u64 = 0;

        let mut attempts = 0;
        while self.active_call.load(Ordering::SeqCst) && attempts < 30 {
            attempts += 1;
            let init_resp = client.get(&initiate_url).send().await;
            match init_resp {
                Ok(resp) => {
                    let text = resp.text().await.unwrap_or_default();
                    if text.contains("-6") {
                        CallStateSignal {
                            state: "queued".to_string(),
                            status_message: "All Relay Assistants are busy. Waiting for next available officer...".to_string(),
                            officer_badge: "".to_string(),
                            recipient_number: req.recipient_phone.clone(),
                            duration_seconds: 0,
                            error_detail: None,
                        }
                        .send_signal_to_dart();
                        sleep(Duration::from_secs(3)).await;
                        continue;
                    } else if text.contains("-5") {
                        CallStateSignal {
                            state: "queued".to_string(),
                            status_message: "In queue for next available Relay Officer...".to_string(),
                            officer_badge: "".to_string(),
                            recipient_number: req.recipient_phone.clone(),
                            duration_seconds: 0,
                            error_detail: None,
                        }
                        .send_signal_to_dart();
                        sleep(Duration::from_secs(3)).await;
                        continue;
                    } else if let Ok(val) = serde_json::from_str::<serde_json::Value>(&text) {
                        if let Some(arr) = val.as_array() {
                            if let Some(first) = arr.first() {
                                if let Some(room) = first.get("ChatRoomId").and_then(|v| v.as_str()) {
                                    chat_room_id = room.to_string();
                                }
                                if let Some(agent) = first.get("AgentName").and_then(|v| v.as_str()) {
                                    if !agent.trim().is_empty() {
                                        agent_name = agent.trim().to_string();
                                    }
                                }
                                if let Some(p) = first.get("pagehisto").and_then(|v| v.as_u64()) {
                                    page_histo = p;
                                }
                                break;
                            }
                        }
                    }
                }
                Err(e) => {
                    self.record_and_emit_message("system", &format!("Handshake attempt error: {}", e)).await;
                    sleep(Duration::from_secs(2)).await;
                }
            }
        }

        if !self.active_call.load(Ordering::SeqCst) {
            return;
        }

        // Store active session details
        {
            let mut s = self.session.lock().await;
            *s = Some(ConcentrixSession {
                session_id: session_id.clone(),
                chat_room_id: chat_room_id.clone(),
                campaign_key: campaign.to_string(),
                omni_shell_base: omni_shell_base.to_string(),
                page_histo,
            });
        }

        CallStateSignal {
            state: "connected".to_string(),
            status_message: format!("Connected with {}", agent_name),
            officer_badge: agent_name.clone(),
            recipient_number: req.recipient_phone.clone(),
            duration_seconds: 0,
            error_detail: None,
        }
        .send_signal_to_dart();

        if is_nz {
            self.record_and_emit_message(
                "officer_system",
                &format!("New Zealand Relay Service session active. Connected to {}. Calling {}. GA", agent_name, req.recipient_phone),
            )
            .await;
        } else {
            self.record_and_emit_message(
                "officer_system",
                &format!("National Relay Service session active. Connected to {}. Calling {}. GA", agent_name, req.recipient_phone),
            )
            .await;
        }

        if !req.call_notes.trim().is_empty() {
            let note = format!("Call Note: {}", req.call_notes.trim());
            self.record_and_emit_message("user", &note).await;
            self.send_concentrix_message(&note).await;
        }

        // Step 7: Live polling loop for incoming relay messages
        let client_poll = client.clone();
        let actor_poll = Arc::new(self.clone());
        let active_poll = self.active_call.clone();
        let sess_arc = self.session.clone();

        spawn(async move {
            while active_poll.load(Ordering::SeqCst) {
                sleep(Duration::from_millis(1500)).await;
                if !active_poll.load(Ordering::SeqCst) {
                    break;
                }

                let current_session = {
                    let guard = sess_arc.lock().await;
                    guard.clone()
                };

                if let Some(mut sess) = current_session {
                    let poll_url = format!(
                        "{}/GetNewMessages?SessionId={}&ChatRoomId={}&ClientKey={}&CampaignKey={}&pagehisto={}",
                        sess.omni_shell_base, sess.session_id, sess.chat_room_id, CLIENT_KEY, sess.campaign_key, sess.page_histo
                    );

                    if let Ok(resp) = client_poll.get(&poll_url).send().await {
                        if let Ok(text) = resp.text().await {
                            let trimmed = text.trim();
                            if !trimmed.is_empty() && trimmed != "null" {
                                if let Ok(val) = serde_json::from_str::<serde_json::Value>(trimmed) {
                                    if let Some(arr) = val.as_array() {
                                        for item in arr {
                                            if let Some(status) = item.get("ChatStatus").and_then(|s| s.as_i64()) {
                                                if status != 0 {
                                                    actor_poll.handle_disconnect("Relay Officer ended session".to_string()).await;
                                                    return;
                                                }
                                            }

                                            if let Some(raw_msg) = item.get("Message").and_then(|m| m.as_str()) {
                                                if let Ok(inner) = serde_json::from_str::<serde_json::Value>(raw_msg) {
                                                    if let Some(msg_list) = inner.as_array() {
                                                        for m in msg_list {
                                                            if let Some(text_content) = m.get("message").and_then(|t| t.as_str()) {
                                                                let clean = text_content
                                                                    .replace("<BR>", "\n")
                                                                    .replace("<br>", "\n")
                                                                    .replace("<br/>", "\n");
                                                                let trimmed_clean = clean.trim();
                                                                if !trimmed_clean.is_empty() {
                                                                    let from_name = m.get("fromName").and_then(|f| f.as_str()).unwrap_or("Relay Officer");
                                                                    let sender_role = if from_name.to_lowercase().contains("system") {
                                                                        "officer_system"
                                                                    } else {
                                                                        "officer_speech"
                                                                    };
                                                                    actor_poll.record_and_emit_message(sender_role, trimmed_clean).await;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Increment page history sequence
                    sess.page_histo += 1;
                    {
                        let mut guard = sess_arc.lock().await;
                        *guard = Some(sess);
                    }
                }
            }
        });
    }

fn url_encode(input: &str) -> String {
    let mut out = String::new();
    for b in input.bytes() {
        match b {
            b'a'..=b'z' | b'A'..=b'Z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => out.push(b as char),
            b' ' => out.push('+'),
            _ => out.push_str(&format!("%{:02X}", b)),
        }
    }
    out
}

    async fn send_concentrix_message(&self, message: &str) {
        let current_session = {
            let guard = self.session.lock().await;
            guard.clone()
        };
        let client_opt = {
            let guard = self.http_client.lock().await;
            guard.clone()
        };

        if let (Some(sess), Some(client)) = (current_session, client_opt) {
            let encoded_msg = Self::url_encode(message);
            let send_url = format!(
                "{}/SendMessage?SessionId={}&ChatRoomId={}&Message={}&ClientKey={}&CampaignKey={}&pagehisto={}",
                sess.omni_shell_base, sess.session_id, sess.chat_room_id, encoded_msg, CLIENT_KEY, sess.campaign_key, sess.page_histo
            );
            let _ = client.get(&send_url).send().await;
        }
    }

    async fn handle_send_message(&self, req: SendRelayMessageRequest) {
        if !self.active_call.load(Ordering::SeqCst) {
            return;
        }

        let mut text = req.text.trim().to_string();
        if text.is_empty() {
            return;
        }

        if req.append_ga && !text.ends_with("GA") && !text.ends_with("SK") && !text.ends_with("SKSK") {
            text.push_str(" GA");
        }

        self.record_and_emit_message("user", &text).await;
        self.send_concentrix_message(&text).await;
    }

    async fn handle_quick_action(&self, req: QuickActionRequest) {
        if !self.active_call.load(Ordering::SeqCst) {
            return;
        }

        match req.action_type.as_str() {
            "GA" => self.handle_send_message(SendRelayMessageRequest { text: "GA".to_string(), append_ga: false }).await,
            "GA_TO_SK" => self.handle_send_message(SendRelayMessageRequest { text: "GA TO SK".to_string(), append_ga: false }).await,
            "SK" => self.handle_send_message(SendRelayMessageRequest { text: "SK".to_string(), append_ga: false }).await,
            "SKSK" => {
                self.handle_send_message(SendRelayMessageRequest { text: "SKSK".to_string(), append_ga: false }).await;
                self.handle_disconnect("User hung up (SKSK)".to_string()).await;
            }
            "HOLD" => {
                self.record_and_emit_message("officer_system", "Call placed on hold by user.").await;
                CallStateSignal {
                    state: "on_hold".to_string(),
                    status_message: "Call is on hold".to_string(),
                    officer_badge: "".to_string(),
                    recipient_number: "".to_string(),
                    duration_seconds: self.call_duration.load(Ordering::SeqCst),
                    error_detail: None,
                }
                .send_signal_to_dart();
            }
            "RESUME" => {
                self.record_and_emit_message("officer_system", "Call resumed.").await;
                CallStateSignal {
                    state: "connected".to_string(),
                    status_message: "Call resumed".to_string(),
                    officer_badge: "".to_string(),
                    recipient_number: "".to_string(),
                    duration_seconds: self.call_duration.load(Ordering::SeqCst),
                    error_detail: None,
                }
                .send_signal_to_dart();
            }
            "REPEAT" => {
                self.handle_send_message(SendRelayMessageRequest { text: "Please repeat GA".to_string(), append_ga: false }).await;
            }
            "SPELL" => {
                self.handle_send_message(SendRelayMessageRequest { text: "Please spell that GA".to_string(), append_ga: false }).await;
            }
            "EMERGENCY_000" => {
                self.record_and_emit_message("system", "PRIORITY EMERGENCY 000 RELAY ACTIVE").await;
            }
            "EMERGENCY_111" => {
                self.record_and_emit_message("system", "PRIORITY EMERGENCY 111 RELAY ACTIVE").await;
            }
            _ => {}
        }
    }

    async fn handle_error(&self, error_msg: &str, recipient_phone: &str) {
        self.active_call.store(false, Ordering::SeqCst);
        self.record_and_emit_message("system", &format!("ERROR: {}", error_msg)).await;
        CallStateSignal {
            state: "error".to_string(),
            status_message: "Connection Error".to_string(),
            officer_badge: "".to_string(),
            recipient_number: recipient_phone.to_string(),
            duration_seconds: 0,
            error_detail: Some(error_msg.to_string()),
        }
        .send_signal_to_dart();
    }

    async fn handle_disconnect(&self, reason: String) {
        self.active_call.store(false, Ordering::SeqCst);
        let duration = self.call_duration.load(Ordering::SeqCst);

        let current_session = {
            let guard = self.session.lock().await;
            guard.clone()
        };
        let client_opt = {
            let guard = self.http_client.lock().await;
            guard.clone()
        };

        if let (Some(sess), Some(client)) = (current_session, client_opt) {
            let end_url = format!("{}/EndChat?SessionId={}", sess.omni_shell_base, sess.session_id);
            spawn(async move {
                let _ = client.get(&end_url).send().await;
            });
        }

        CallStateSignal {
            state: "ended".to_string(),
            status_message: format!("Call ended: {}", reason),
            officer_badge: "".to_string(),
            recipient_number: "".to_string(),
            duration_seconds: duration,
            error_detail: None,
        }
        .send_signal_to_dart();

        self.record_and_emit_message("system", &format!("Call ended ({})", reason)).await;
    }

    async fn handle_export(&self, format: String) {
        let msgs = self.messages.lock().await;
        let date_str = Local::now().format("%Y%m%d_%H%M%S").to_string();
        let is_nz = {
            let guard = self.current_country.lock().await;
            guard.eq_ignore_ascii_case("NZ")
        };

        let service_name = if is_nz {
            "NZ Relay (Text Relay)"
        } else {
            "Internet Relay"
        };

        let file_prefix = if is_nz {
            "nzrelay_transcript"
        } else {
            "nrs_transcript"
        };

        if format == "json" {
            let json_val = serde_json::json!({
                "relay_service": service_name,
                "country": if is_nz { "NZ" } else { "AU" },
                "export_date": Local::now().to_rfc3339(),
                "duration_seconds": self.call_duration.load(Ordering::SeqCst),
                "messages": msgs.iter().map(|m| {
                    serde_json::json!({
                        "timestamp": m.timestamp,
                        "sender": m.sender,
                        "content": m.content,
                    })
                }).collect::<Vec<_>>()
            });

            let content = serde_json::to_string_pretty(&json_val).unwrap_or_default();
            TranscriptExportedSignal {
                success: true,
                filename: format!("{}_{}.json", file_prefix, date_str),
                content,
                message: "Transcript exported as JSON".to_string(),
            }
            .send_signal_to_dart();
        } else {
            let mut out = String::new();
            out.push_str("==============================================\n");
            if is_nz {
                out.push_str("NEW ZEALAND RELAY (NZ RELAY) - TEXT RELAY CHAT\n");
            } else {
                out.push_str("NATIONAL RELAY SERVICE - INTERNET RELAY CHAT\n");
            }
            out.push_str(&format!("Transcript Date: {}\n", Local::now().to_rfc2822()));
            out.push_str(&format!("Total Duration: {}s\n", self.call_duration.load(Ordering::SeqCst)));
            out.push_str("==============================================\n\n");

            for m in msgs.iter() {
                out.push_str(&format!("[{}] {}: {}\n", m.timestamp, m.sender.to_uppercase(), m.content));
            }

            TranscriptExportedSignal {
                success: true,
                filename: format!("{}_{}.txt", file_prefix, date_str),
                content: out,
                message: "Transcript exported as TXT".to_string(),
            }
            .send_signal_to_dart();
        }
    }
}

impl Clone for CallActor {
    fn clone(&self) -> Self {
        Self {
            active_call: self.active_call.clone(),
            call_duration: self.call_duration.clone(),
            messages: self.messages.clone(),
            http_client: self.http_client.clone(),
            session: self.session.clone(),
            current_country: self.current_country.clone(),
        }
    }
}
