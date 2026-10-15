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

#[derive(Clone)]
struct StoredMessage {
    timestamp: String,
    sender: String,
    content: String,
}

pub struct CallActor {
    active_call: Arc<AtomicBool>,
    call_duration: Arc<AtomicU64>,
    messages: Arc<Mutex<Vec<StoredMessage>>>,
    http_client: Arc<Mutex<Option<reqwest::Client>>>,
}

impl CallActor {
    pub fn start() {
        let active_call = Arc::new(AtomicBool::new(false));
        let call_duration = Arc::new(AtomicU64::new(0));
        let messages = Arc::new(Mutex::new(Vec::new()));
        let http_client = Arc::new(Mutex::new(None));

        let actor = Arc::new(Self {
            active_call: active_call.clone(),
            call_duration: call_duration.clone(),
            messages: messages.clone(),
            http_client: http_client.clone(),
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
        let has_ga = content.trim().ends_with("GA")
            || content.trim().ends_with("ga")
            || content.trim().ends_with("GA TO SK")
            || content.trim().ends_with("SK")
            || content.trim().ends_with("SKSK");

        let msg_id = format!("msg_{}", Local::now().timestamp_millis());

        // Store internally
        {
            let mut msgs = self.messages.lock().await;
            msgs.push(StoredMessage {
                timestamp: now.clone(),
                sender: sender.to_string(),
                content: content.to_string(),
            });
        }

        // Send RustSignal to Dart
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

        CallStateSignal {
            state: "connecting".to_string(),
            status_message: "Connecting to https://nrschat.nrscall.gov.au/nrs/internetrelay...".to_string(),
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

        // Spawn timer task
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

        // Run live NRS session
        spawn(async move {
            actor_for_session.run_live_nrs_session(req).await;
        });
    }

    async fn run_live_nrs_session(&self, req: ConnectCallRequest) {
        let mut client_builder = reqwest::Client::builder()
            .timeout(Duration::from_secs(15))
            .cookie_store(true)
            .redirect(reqwest::redirect::Policy::none());

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
                self.record_and_emit_message("system", &format!("Failed to build HTTP client: {}", e)).await;
                self.handle_disconnect(format!("Client build error: {}", e)).await;
                return;
            }
        };

        // Save client in mutex for subsequent message requests
        {
            let mut guard = self.http_client.lock().await;
            *guard = Some(client.clone());
        }

        let is_emergency = req.recipient_phone == "000" || req.recipient_phone == "112" || req.recipient_phone == "911";
        let campaign = if is_emergency {
            "P_NRS_Emergency_InternetRelay_Chat"
        } else {
            "P_NRS_Internet_MakeACall_Chat"
        };
        let chat_msg = if is_emergency {
            "Emergency internet relay chat"
        } else {
            "You are using NRS Chat"
        };

        self.record_and_emit_message("system", "Initiating HTTPS connection to National Relay Service gateway...").await;

        let gateway_url = "https://nrschat.nrscall.gov.au/nrs/internetrelay";
        let resp = client
            .get(gateway_url)
            .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
            .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
            .send()
            .await;

        match resp {
            Ok(r) => {
                let status = r.status();
                let loc = r.headers().get("location").and_then(|l| l.to_str().ok()).unwrap_or("");

                if loc.contains("geoinfo.html") {
                    self.record_and_emit_message(
                        "system",
                        "ERROR: Gateway redirected to geoinfo.html (Foreign IP blocked). Australian IP required.",
                    )
                    .await;
                    CallStateSignal {
                        state: "error".to_string(),
                        status_message: "Geo-blocked: Australian IP address required.".to_string(),
                        officer_badge: "".to_string(),
                        recipient_number: req.recipient_phone.clone(),
                        duration_seconds: 0,
                        error_detail: Some(
                            "Australian GeoIP restriction encountered. Please configure an Australian proxy in Settings to access this service."
                                .to_string(),
                        ),
                    }
                    .send_signal_to_dart();
                    self.active_call.store(false, Ordering::SeqCst);
                    return;
                }

                self.record_and_emit_message(
                    "system",
                    &format!("Connected to NRS Gateway (HTTP {}). Initializing relay session for {}...", status.as_u16(), req.recipient_phone),
                )
                .await;

                // Send session initialization payload to gateway
                let post_resp = client
                    .post(gateway_url)
                    .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
                    .header("Referer", gateway_url)
                    .form(&[
                        ("txtNRSNumber", req.caller_phone.as_str()),
                        ("txtOPNumber", req.recipient_phone.as_str()),
                        ("txtCampaignName", campaign),
                        ("txtState", req.australian_state.as_str()),
                        ("chatMsg", chat_msg),
                        ("callNotes", req.call_notes.as_str()),
                    ])
                    .send()
                    .await;

                match post_resp {
                    Ok(p_resp) => {
                        let p_status = p_resp.status();

                        CallStateSignal {
                            state: "connected".to_string(),
                            status_message: format!("Relay call session established (HTTP {})", p_status.as_u16()),
                            officer_badge: "".to_string(),
                            recipient_number: req.recipient_phone.clone(),
                            duration_seconds: 0,
                            error_detail: None,
                        }
                        .send_signal_to_dart();

                        self.record_and_emit_message(
                            "officer_system",
                            &format!("National Relay Service session active. Calling {}. GA", req.recipient_phone),
                        )
                        .await;

                        if !req.call_notes.trim().is_empty() {
                            self.record_and_emit_message("user", &format!("Call Note: {}", req.call_notes.trim())).await;
                        }

                        // Gateway polling loop: poll for incoming messages from the live gateway
                        let client_poll = client.clone();
                        let actor_poll = Arc::new(self.clone());
                        let active_poll = self.active_call.clone();

                        spawn(async move {
                            while active_poll.load(Ordering::SeqCst) {
                                sleep(Duration::from_millis(2000)).await;
                                if !active_poll.load(Ordering::SeqCst) {
                                    break;
                                }

                                // Check for incoming messages from the live gateway
                                let poll_res = client_poll
                                    .get("https://nrschat.nrscall.gov.au/nrs/poll")
                                    .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
                                    .header("Referer", gateway_url)
                                    .send()
                                    .await;

                                if let Ok(resp) = poll_res {
                                    if resp.status().is_success() {
                                        if let Ok(text) = resp.text().await {
                                            let trimmed = text.trim();
                                            if !trimmed.is_empty() && !trimmed.contains("<html>") {
                                                if let Ok(val) = serde_json::from_str::<serde_json::Value>(trimmed) {
                                                    if let Some(arr) = val.as_array() {
                                                        for item in arr {
                                                            if let Some(msg) = item.get("text").or_else(|| item.get("message")).and_then(|m| m.as_str()) {
                                                                actor_poll.record_and_emit_message("officer_speech", msg).await;
                                                            }
                                                        }
                                                    } else if let Some(msg) = val.get("message").or_else(|| val.get("text")).and_then(|m| m.as_str()) {
                                                        actor_poll.record_and_emit_message("officer_speech", msg).await;
                                                    }
                                                } else {
                                                    actor_poll.record_and_emit_message("officer_speech", trimmed).await;
                                                }
                                            }
                                        }
                                    }
                                }

                            }
                        });
                    }
                    Err(e) => {
                        self.record_and_emit_message("system", &format!("Gateway request failed: {}", e)).await;
                        self.handle_disconnect(format!("Gateway post error: {}", e)).await;
                    }
                }
            }
            Err(e) => {
                self.record_and_emit_message("system", &format!("Network connection error: {}", e)).await;
                self.handle_disconnect(format!("Connection error: {}", e)).await;
            }
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

        // Post message to the real gateway
        let client_opt = self.http_client.lock().await.clone();
        if let Some(client) = client_opt {
            let msg_text = text.clone();
            spawn(async move {
                let _ = client
                    .post("https://nrschat.nrscall.gov.au/nrs/send")
                    .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
                    .header("Referer", "https://nrschat.nrscall.gov.au/nrs/internetrelay")
                    .form(&[("message", msg_text.as_str())])
                    .send()
                    .await;
            });
        }
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
                self.record_and_emit_message("system", "PRIORITY CALL TO 000 (EMERGENCY)").await;
            }
            _ => {}
        }
    }

    async fn handle_disconnect(&self, reason: String) {
        self.active_call.store(false, Ordering::SeqCst);
        let duration = self.call_duration.load(Ordering::SeqCst);

        // Notify gateway of disconnect
        let client_opt = self.http_client.lock().await.clone();
        if let Some(client) = client_opt {
            spawn(async move {
                let _ = client
                    .post("https://nrschat.nrscall.gov.au/nrs/disconnect")
                    .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
                    .send()
                    .await;
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

        if format == "json" {
            let json_val = serde_json::json!({
                "nrs_service": "Internet Relay",
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
                filename: format!("nrs_transcript_{}.json", date_str),
                content,
                message: "Transcript exported as JSON".to_string(),
            }
            .send_signal_to_dart();
        } else {
            let mut out = String::new();
            out.push_str("==============================================\n");
            out.push_str("NATIONAL RELAY SERVICE - INTERNET RELAY CHAT\n");
            out.push_str(&format!("Transcript Date: {}\n", Local::now().to_rfc2822()));
            out.push_str(&format!("Total Duration: {}s\n", self.call_duration.load(Ordering::SeqCst)));
            out.push_str("==============================================\n\n");

            for m in msgs.iter() {
                out.push_str(&format!("[{}] {}: {}\n", m.timestamp, m.sender.to_uppercase(), m.content));
            }

            TranscriptExportedSignal {
                success: true,
                filename: format!("nrs_transcript_{}.txt", date_str),
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
        }
    }
}
