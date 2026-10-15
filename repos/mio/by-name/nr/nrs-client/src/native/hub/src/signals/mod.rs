use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

// ==========================================
// Dart -> Rust Signals (Commands from Flutter)
// ==========================================

#[allow(dead_code)]
#[derive(Deserialize, DartSignal)]
pub struct ConnectCallRequest {
    pub caller_name: String,
    pub caller_phone: String,
    pub recipient_phone: String,
    pub call_notes: String,
    pub proxy_url: Option<String>,
    pub australian_state: String,
    pub password: Option<String>,
    pub user_token: Option<String>,
}

#[derive(Deserialize, DartSignal)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
    pub proxy_url: Option<String>,
}

#[derive(Deserialize, DartSignal)]
pub struct SendRelayMessageRequest {
    pub text: String,
    pub append_ga: bool,
}

#[derive(Deserialize, DartSignal)]
pub struct QuickActionRequest {
    /// Action codes: "GA", "GA_TO_SK", "SK", "SKSK", "HOLD", "RESUME", "REPEAT", "SPELL", "EMERGENCY_000"
    pub action_type: String,
}

#[derive(Deserialize, DartSignal)]
pub struct DisconnectCallRequest {
    pub reason: String,
}

#[derive(Deserialize, DartSignal)]
pub struct CheckGeoStatusRequest {
    pub proxy_url: Option<String>,
}

#[derive(Deserialize, DartSignal)]
pub struct ExportTranscriptRequest {
    /// "txt" or "json"
    pub format: String,
}

// ==========================================
// Rust -> Dart Signals (Events to Flutter)
// ==========================================

#[derive(Serialize, RustSignal)]
pub struct CallStateSignal {
    /// "idle", "connecting", "queued", "officer_assigned", "dialing", "ringing", "connected", "on_hold", "ended", "error"
    pub state: String,
    pub status_message: String,
    pub officer_badge: String,
    pub recipient_number: String,
    pub duration_seconds: u64,
    pub error_detail: Option<String>,
}

#[derive(Serialize, RustSignal)]
pub struct RelayMessageSignal {
    pub id: String,
    pub timestamp: String,
    /// "user", "officer_system", "officer_speech", "recipient", "system"
    pub sender: String,
    pub content: String,
    pub has_ga: bool,
}

#[derive(Serialize, RustSignal)]
pub struct GeoStatusSignal {
    /// "direct_au", "proxy_au", "geo_blocked", "testing", "error"
    pub status: String,
    pub detected_ip: String,
    pub country: String,
    pub details: String,
}

#[derive(Serialize, RustSignal)]
pub struct TranscriptExportedSignal {
    pub success: bool,
    pub filename: String,
    pub content: String,
    pub message: String,
}

#[derive(Serialize, RustSignal)]
pub struct AuthStatusSignal {
    pub is_authenticated: bool,
    pub username: String,
    pub user_token: String,
    pub first_name: String,
    pub last_name: String,
    pub nrs_id: String,
    pub error_message: Option<String>,
}
