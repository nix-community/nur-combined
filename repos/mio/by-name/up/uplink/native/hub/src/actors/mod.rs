use crate::signals::{
    UploadFileRequest, UploadFileResponse, UploadTextRequest, UploadTextResponse,
};
use rinf::{DartSignal, RustSignal, DartSignalBinary};

// The logic has been moved to uplink_core.
// We just re-export it or use it here.
use uplink_core::{upload_text, upload_file};

pub async fn run_upload_actor() {
    let text_receiver = UploadTextRequest::get_dart_signal_receiver();
    let file_receiver = UploadFileRequest::get_dart_signal_receiver();

    loop {
        tokio::select! {
            Some(signal) = text_receiver.recv() => {
                let req = signal.message;
                tokio::spawn(async move {
                    let (url, error) = match upload_text(&req.text).await {
                        Ok(u) => (Some(u), None),
                        Err(e) => (None, Some(e)),
                    };
                    UploadTextResponse { url, error }.send_signal_to_dart();
                });
            }
            Some(signal) = file_receiver.recv() => {
                let req = signal.message;
                let data = signal.binary;
                tokio::spawn(async move {
                    let (url, error) = match upload_file(req.filename, data).await {
                        Ok(u) => (Some(u), None),
                        Err(e) => (None, Some(e)),
                    };
                    UploadFileResponse { url, error }.send_signal_to_dart();
                });
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_upload_text_success() {
        let result = upload_text("Hello from Uplink Test!").await;
        assert!(result.is_ok());
    }
}
