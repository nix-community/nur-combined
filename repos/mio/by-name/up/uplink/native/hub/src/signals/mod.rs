use rinf::{DartSignal, DartSignalBinary, RustSignal};
use serde::{Deserialize, Serialize};

#[derive(Deserialize, DartSignal)]
pub struct UploadTextRequest {
  pub text: String,
}

#[derive(Serialize, RustSignal)]
pub struct UploadTextResponse {
  pub url: Option<String>,
  pub error: Option<String>,
}

#[derive(Deserialize, DartSignalBinary)]
pub struct UploadFileRequest {
  pub filename: String,
}

#[derive(Serialize, RustSignal)]
pub struct UploadFileResponse {
  pub url: Option<String>,
  pub error: Option<String>,
}

/// Upload byte progress for the current provider attempt.
#[derive(Serialize, RustSignal)]
pub struct UploadProgress {
  pub bytes_sent: u64,
  pub bytes_total: u64,
}
