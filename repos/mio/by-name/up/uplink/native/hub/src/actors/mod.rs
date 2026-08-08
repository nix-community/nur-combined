use crate::signals::{
    UploadFileRequest, UploadFileResponse, UploadTextRequest, UploadTextResponse,
};
use rinf::{DartSignal, RustSignal, DartSignalBinary};

/// Uploads text to paste.rs and returns the URL or an error.
pub async fn upload_text(text: &str) -> Result<String, String> {
    let client = reqwest::Client::new();
    let res = client
        .post("https://paste.rs/")
        .body(text.to_owned())
        .send()
        .await
        .map_err(|e| e.to_string())?;

    if res.status().is_success() {
        let t = res.text().await.map_err(|e| e.to_string())?;
        Ok(t.trim().to_string())
    } else {
        Err(format!("HTTP {}", res.status()))
    }
}

/// Uploads a file to catbox.moe and returns the URL or an error.
pub async fn upload_file(filename: String, data: Vec<u8>) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::bytes(data).file_name(filename);
    let form = reqwest::multipart::Form::new()
        .text("reqtype", "fileupload")
        .part("fileToUpload", part);

    let res = client
        .post("https://catbox.moe/user/api.php")
        .multipart(form)
        .send()
        .await
        .map_err(|e| e.to_string())?;

    if res.status().is_success() {
        let t = res.text().await.map_err(|e| e.to_string())?;
        Ok(t.trim().to_string())
    } else {
        Err(format!("HTTP {}", res.status()))
    }
}

pub async fn run_upload_actor() {
    let mut text_receiver = UploadTextRequest::get_dart_signal_receiver();
    let mut file_receiver = UploadFileRequest::get_dart_signal_receiver();

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
        // This is an integration test that actually hits paste.rs
        // In a real environment, we would mock the reqwest client.
        // For demonstration, we just check if it returns a string (the URL) on valid input.
        let result = upload_text("Hello from Uplink Test!").await;
        assert!(result.is_ok());
        let url = result.unwrap();
        assert!(url.starts_with("https://paste.rs/"));
    }
}
