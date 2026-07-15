use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

#[derive(Deserialize, DartSignal)]
pub struct StartSession {
    pub session_id: i64,
    pub host: String,
    pub cols: u16,
    pub rows: u16,
}

#[derive(Deserialize, DartSignal)]
pub struct WriteSession {
    pub session_id: i64,
    pub data: Vec<u8>,
}

#[derive(Deserialize, DartSignal)]
pub struct ResizeSession {
    pub session_id: i64,
    pub cols: u16,
    pub rows: u16,
}

#[derive(Deserialize, DartSignal)]
pub struct StopSession {
    pub session_id: i64,
}

#[derive(Deserialize, DartSignal)]
pub struct GetSshHosts {}

#[derive(Serialize, RustSignal)]
pub struct SshHostsResult {
    pub hosts: Vec<String>,
}

#[derive(Serialize, RustSignal)]
pub struct TerminalOutput {
    pub session_id: i64,
    pub data: Vec<u8>,
}

#[derive(Serialize, RustSignal)]
pub struct TerminalExit {
    pub session_id: i64,
    pub status: Option<i32>,
}
