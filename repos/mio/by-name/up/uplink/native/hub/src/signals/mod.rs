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
