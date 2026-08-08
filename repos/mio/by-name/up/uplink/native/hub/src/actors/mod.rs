use crate::signals::{
    UploadFileRequest, UploadFileResponse, UploadTextRequest, UploadTextResponse,
};
use rinf::{DartSignal, RustSignal, DartSignalBinary};

/// Uploads text and returns the URL or an error. Tries multiple providers.
pub async fn upload_text(text: &str) -> Result<String, String> {
    let client = reqwest::Client::new();
    let mut last_err = String::new();

    // Provider 1: paste.rs
    match client
        .post("https://paste.rs/")
        .body(text.to_owned())
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(t) = res.text().await {
                return Ok(t.trim().to_string());
            }
        }
        Err(e) => last_err = e.to_string(),
        Ok(res) => last_err = format!("paste.rs HTTP {}", res.status()),
    }

    // Provider 2: 0x0.st (multipart file upload with text content)
    let part = reqwest::multipart::Part::text(text.to_owned()).file_name("paste.txt");
    let form = reqwest::multipart::Form::new().part("file", part);
    match client
        .post("https://0x0.st")
        .multipart(form)
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(t) = res.text().await {
                return Ok(t.trim().to_string());
            }
        }
        Err(e) => last_err = e.to_string(),
        Ok(res) => last_err = format!("0x0.st HTTP {}", res.status()),
    }

    Err(format!("All text upload providers failed. Last error: {}", last_err))
}

/// Uploads a file and returns the URL or an error. Tries multiple providers.
pub async fn upload_file(filename: String, data: Vec<u8>) -> Result<String, String> {
    let client = reqwest::Client::new();
    let mut last_err = String::new();

    // Provider 1: catbox.moe
    let part = reqwest::multipart::Part::bytes(data.clone()).file_name(filename.clone());
    let form = reqwest::multipart::Form::new()
        .text("reqtype", "fileupload")
        .part("fileToUpload", part);

    match client
        .post("https://catbox.moe/user/api.php")
        .multipart(form)
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(t) = res.text().await {
                return Ok(t.trim().to_string());
            }
        }
        Err(e) => last_err = e.to_string(),
        Ok(res) => last_err = format!("catbox.moe HTTP {}", res.status()),
    }

    // Provider 2: 0x0.st
    let part = reqwest::multipart::Part::bytes(data.clone()).file_name(filename.clone());
    let form = reqwest::multipart::Form::new().part("file", part);

    match client
        .post("https://0x0.st")
        .multipart(form)
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(t) = res.text().await {
                return Ok(t.trim().to_string());
            }
        }
        Err(e) => last_err = e.to_string(),
        Ok(res) => last_err = format!("0x0.st HTTP {}", res.status()),
    }
    
    // Provider 3: uguu.se
    let part = reqwest::multipart::Part::bytes(data).file_name(filename);
    let form = reqwest::multipart::Form::new().part("files[]", part);

    match client
        .post("https://uguu.se/upload.php")
        .multipart(form)
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(json) = res.json::<serde_json::Value>().await {
                if let Some(files) = json.get("files").and_then(|f| f.as_array()) {
                    if let Some(first_file) = files.first() {
                        if let Some(url) = first_file.get("url").and_then(|u| u.as_str()) {
                            return Ok(url.to_string());
                        }
                    }
                }
            }
        }
        Err(e) => last_err = e.to_string(),
        Ok(res) => last_err = format!("uguu.se HTTP {}", res.status()),
    }

    Err(format!("All file upload providers failed. Last error: {}", last_err))
}

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
