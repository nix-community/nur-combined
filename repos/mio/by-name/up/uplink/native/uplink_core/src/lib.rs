use bytes::Bytes;
use futures_util::stream;
use reqwest::Body;
use std::sync::Arc;

/// Reports `(bytes_sent, bytes_total)` for the current upload attempt.
pub type ProgressCallback = Arc<dyn Fn(u64, u64) + Send + Sync>;

const CHUNK_SIZE: usize = 64 * 1024;

fn report(on_progress: &Option<ProgressCallback>, sent: u64, total: u64) {
    if let Some(cb) = on_progress {
        cb(sent, total);
    }
}

/// Streaming body that reports progress as chunks are pulled for upload.
fn body_with_progress(data: Vec<u8>, on_progress: Option<ProgressCallback>) -> (Body, u64) {
    let data = Bytes::from(data);
    let total = data.len() as u64;
    report(&on_progress, 0, total);

    let stream = stream::unfold(
        (data, 0usize, on_progress),
        move |(data, offset, on_progress)| async move {
            if offset >= data.len() {
                return None;
            }
            let end = (offset + CHUNK_SIZE).min(data.len());
            let chunk = data.slice(offset..end);
            report(&on_progress, end as u64, total);
            Some((Ok::<Bytes, std::io::Error>(chunk), (data, end, on_progress)))
        },
    );

    (Body::wrap_stream(stream), total)
}

fn file_part(
    filename: &str,
    data: Vec<u8>,
    on_progress: Option<ProgressCallback>,
) -> reqwest::multipart::Part {
    let (body, len) = body_with_progress(data, on_progress);
    reqwest::multipart::Part::stream_with_length(body, len).file_name(filename.to_owned())
}

pub async fn upload_text_paste_rs(
    text: &str,
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::new();
    let (body, _) = body_with_progress(text.as_bytes().to_vec(), on_progress);
    match client.post("https://paste.rs/").body(body).send().await {
        Ok(res) if res.status().is_success() => {
            Ok(res.text().await.unwrap_or_default().trim().to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("paste.rs HTTP {}", res.status())),
    }
}

pub async fn upload_text_0x0(
    text: &str,
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::builder()
        .user_agent("curl/8.4.0")
        .build()
        .map_err(|e| e.to_string())?;
    let part = file_part("paste.txt", text.as_bytes().to_vec(), on_progress);
    let form = reqwest::multipart::Form::new().part("file", part);
    match client.post("https://0x0.st").multipart(form).send().await {
        Ok(res) if res.status().is_success() => {
            Ok(res.text().await.unwrap_or_default().trim().to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("0x0.st HTTP {}", res.status())),
    }
}

pub async fn upload_text(
    text: &str,
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let mut last_err = String::new();

    match upload_text_paste_rs(text, on_progress.clone()).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_text_0x0(text, on_progress).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    Err(format!(
        "All text upload providers failed. Last error: {}",
        last_err
    ))
}

pub async fn upload_file_catbox(
    filename: &str,
    data: &[u8],
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::builder()
        .user_agent("curl/8.4.0")
        .build()
        .map_err(|e| e.to_string())?;
    let part = file_part(filename, data.to_vec(), on_progress);
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
            Ok(res.text().await.unwrap_or_default().trim().to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("catbox.moe HTTP {}", res.status())),
    }
}

pub async fn upload_file_0x0(
    filename: &str,
    data: &[u8],
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::builder()
        .user_agent("curl/8.4.0")
        .build()
        .map_err(|e| e.to_string())?;
    let part = file_part(filename, data.to_vec(), on_progress);
    let form = reqwest::multipart::Form::new().part("file", part);

    match client.post("https://0x0.st").multipart(form).send().await {
        Ok(res) if res.status().is_success() => {
            Ok(res.text().await.unwrap_or_default().trim().to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("0x0.st HTTP {}", res.status())),
    }
}

pub async fn upload_file_uguu(
    filename: &str,
    data: &[u8],
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::builder()
        .user_agent("curl/8.4.0")
        .build()
        .map_err(|e| e.to_string())?;
    let part = file_part(filename, data.to_vec(), on_progress);
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
            Err("Failed to parse JSON response".to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("uguu.se HTTP {}", res.status())),
    }
}

pub async fn upload_file_pasteboard(
    filename: &str,
    data: &[u8],
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let client = reqwest::Client::builder()
        .user_agent("curl/8.4.0")
        .build()
        .map_err(|e| e.to_string())?;
    let part = file_part(filename, data.to_vec(), on_progress);
    let form = reqwest::multipart::Form::new().part("file", part);

    match client
        .post("https://www.pasteboard.co/api/upload")
        .multipart(form)
        .send()
        .await
    {
        Ok(res) if res.status().is_success() => {
            if let Ok(json) = res.json::<serde_json::Value>().await {
                if let Some(url) = json.get("url").and_then(|u| u.as_str()) {
                    return Ok(format!("https://pasteboard.co{}", url));
                }
            }
            Err("Failed to parse JSON response".to_string())
        }
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("pasteboard.co HTTP {}", res.status())),
    }
}

pub async fn upload_file(
    filename: String,
    data: Vec<u8>,
    on_progress: Option<ProgressCallback>,
) -> Result<String, String> {
    let mut last_err = String::new();

    match upload_file_catbox(&filename, &data, on_progress.clone()).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_0x0(&filename, &data, on_progress.clone()).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_uguu(&filename, &data, on_progress.clone()).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_pasteboard(&filename, &data, on_progress).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    Err(format!(
        "All file upload providers failed. Last error: {}",
        last_err
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    #[ignore]
    async fn test_upload_text_paste_rs() {
        let res = upload_text_paste_rs("test uplink paste.rs provider", None).await;
        assert!(res.is_ok(), "paste.rs failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://paste.rs/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_text_0x0() {
        let res = upload_text_0x0("test uplink 0x0 provider", None).await;
        assert!(res.is_ok(), "0x0.st failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://0x0.st/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_catbox() {
        let res = upload_file_catbox("test.txt", b"hello catbox", None).await;
        assert!(res.is_ok(), "catbox.moe failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://files.catbox.moe/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_0x0() {
        let res = upload_file_0x0("test.txt", b"hello 0x0", None).await;
        assert!(res.is_ok(), "0x0.st failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://0x0.st/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_uguu() {
        let res = upload_file_uguu("test.txt", b"hello uguu", None).await;
        assert!(res.is_ok(), "uguu.se failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://a.uguu.se/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_pasteboard() {
        let tiny_png: [u8; 67] = [
            0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48,
            0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00,
            0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, 0x78,
            0x9c, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00,
            0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
        ];
        let res = upload_file_pasteboard("test.png", &tiny_png, None).await;
        assert!(res.is_ok(), "pasteboard.co failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://pasteboard.co/"));
    }
}
