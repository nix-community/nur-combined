use crate::signals::{
    UploadFileRequest, UploadFileResponse, UploadProgress, UploadTextRequest, UploadTextResponse,
};
use rinf::{DartSignal, DartSignalBinary, RustSignal};
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};
use uplink_core::{ProgressCallback, upload_file, upload_text};

fn progress_callback() -> ProgressCallback {
    // Throttle UI updates to at most one signal per percentage point.
    let last_pct = Arc::new(AtomicU64::new(u64::MAX));
    Arc::new(move |bytes_sent: u64, bytes_total: u64| {
        let pct = if bytes_total == 0 {
            0
        } else {
            (bytes_sent.saturating_mul(100) / bytes_total).min(100)
        };
        let prev = last_pct.swap(pct, Ordering::Relaxed);
        if prev == pct && bytes_sent != 0 && bytes_sent != bytes_total {
            return;
        }
        UploadProgress {
            bytes_sent,
            bytes_total,
        }
        .send_signal_to_dart();
    })
}

pub async fn run_upload_actor() {
    let text_receiver = UploadTextRequest::get_dart_signal_receiver();
    let file_receiver = UploadFileRequest::get_dart_signal_receiver();

    loop {
        tokio::select! {
            Some(signal) = text_receiver.recv() => {
                let req = signal.message;
                tokio::spawn(async move {
                    let on_progress = Some(progress_callback());
                    let (url, error) = match upload_text(&req.text, on_progress).await {
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
                    let on_progress = Some(progress_callback());
                    let (url, error) = match upload_file(req.filename, data, on_progress).await {
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
        let result = upload_text("Hello from Uplink Test!", None).await;
        assert!(result.is_ok());
    }
}
