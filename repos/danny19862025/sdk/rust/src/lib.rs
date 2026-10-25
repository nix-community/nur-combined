//! Build for wasm32-unknown-unknown; no WASI or JavaScript runtime required.
use serde::{Deserialize, Serialize};

#[link(wasm_import_module = "spotlight")]
unsafe extern "C" {
    fn request_len() -> i32;
    fn read_request(ptr: *mut u8, capacity: i32) -> i32;
    #[link_name = "emit"]
    fn host_emit(ptr: *const u8, len: i32);
}
#[derive(Deserialize, Debug)]
pub struct Request {
    pub api_version: u32,
    pub query: String,
    pub args: Vec<String>,
}
#[derive(Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Action {
    Copy { text: String },
    Open { url: String },
    Run { args: Vec<String> },
}
#[derive(Serialize)]
pub struct ResultItem {
    pub id: String,
    pub title: String,
    pub subtitle: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub icon: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub action: Option<Action>,
}
pub fn request() -> Result<Request, String> {
    let size = unsafe { request_len() };
    if !(0..=524288).contains(&size) {
        return Err("Invalid request length".into());
    }
    let mut data = vec![0; size as usize];
    if unsafe { read_request(data.as_mut_ptr(), size) } != size {
        return Err("Could not read request".into());
    }
    serde_json::from_slice(&data).map_err(|e| e.to_string())
}
fn send(value: &impl Serialize) -> Result<(), String> {
    let json = serde_json::to_vec(value).map_err(|e| e.to_string())?;
    if json.len() > 65535 {
        return Err("Plugin message exceeds 64 KiB".into());
    }
    unsafe {
        host_emit(json.as_ptr(), json.len() as i32);
    }
    Ok(())
}
pub fn emit(item: ResultItem) -> Result<(), String> {
    #[derive(Serialize)]
    struct Message {
        r#type: &'static str,
        #[serde(flatten)]
        item: ResultItem,
    }
    send(&Message {
        r#type: "result",
        item,
    })
}
pub fn status(text: &str) -> Result<(), String> {
    send(&serde_json::json!({"type":"status","text":text}))
}
pub fn done() -> Result<(), String> {
    send(&serde_json::json!({"type":"done"}))
}
