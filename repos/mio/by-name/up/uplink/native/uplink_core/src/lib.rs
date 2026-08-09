pub async fn upload_text_paste_rs(text: &str) -> Result<String, String> {
    let client = reqwest::Client::new();
    match client.post("https://paste.rs/").body(text.to_owned()).send().await {
        Ok(res) if res.status().is_success() => Ok(res.text().await.unwrap_or_default().trim().to_string()),
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("paste.rs HTTP {}", res.status())),
    }
}

pub async fn upload_text_0x0(text: &str) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::text(text.to_owned()).file_name("paste.txt");
    let form = reqwest::multipart::Form::new().part("file", part);
    match client.post("https://0x0.st").multipart(form).send().await {
        Ok(res) if res.status().is_success() => Ok(res.text().await.unwrap_or_default().trim().to_string()),
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("0x0.st HTTP {}", res.status())),
    }
}

pub async fn upload_text(text: &str) -> Result<String, String> {
    let mut last_err = String::new();
    
    match upload_text_paste_rs(text).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_text_0x0(text).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    Err(format!("All text upload providers failed. Last error: {}", last_err))
}

pub async fn upload_file_catbox(filename: &str, data: &[u8]) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::bytes(data.to_vec()).file_name(filename.to_owned());
    let form = reqwest::multipart::Form::new()
        .text("reqtype", "fileupload")
        .part("fileToUpload", part);

    match client.post("https://catbox.moe/user/api.php").multipart(form).send().await {
        Ok(res) if res.status().is_success() => Ok(res.text().await.unwrap_or_default().trim().to_string()),
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("catbox.moe HTTP {}", res.status())),
    }
}

pub async fn upload_file_0x0(filename: &str, data: &[u8]) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::bytes(data.to_vec()).file_name(filename.to_owned());
    let form = reqwest::multipart::Form::new().part("file", part);

    match client.post("https://0x0.st").multipart(form).send().await {
        Ok(res) if res.status().is_success() => Ok(res.text().await.unwrap_or_default().trim().to_string()),
        Err(e) => Err(e.to_string()),
        Ok(res) => Err(format!("0x0.st HTTP {}", res.status())),
    }
}

pub async fn upload_file_uguu(filename: &str, data: &[u8]) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::bytes(data.to_vec()).file_name(filename.to_owned());
    let form = reqwest::multipart::Form::new().part("files[]", part);

    match client.post("https://uguu.se/upload.php").multipart(form).send().await {
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

pub async fn upload_file_pasteboard(filename: &str, data: &[u8]) -> Result<String, String> {
    let client = reqwest::Client::new();
    let part = reqwest::multipart::Part::bytes(data.to_vec()).file_name(filename.to_owned());
    let form = reqwest::multipart::Form::new().part("file", part);

    match client.post("https://www.pasteboard.co/api/upload").multipart(form).send().await {
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

pub async fn upload_file(filename: String, data: Vec<u8>) -> Result<String, String> {
    let mut last_err = String::new();

    match upload_file_catbox(&filename, &data).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_0x0(&filename, &data).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_uguu(&filename, &data).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    match upload_file_pasteboard(&filename, &data).await {
        Ok(url) => return Ok(url),
        Err(e) => last_err = e,
    }

    Err(format!("All file upload providers failed. Last error: {}", last_err))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    #[ignore]
    async fn test_upload_text_paste_rs() {
        let res = upload_text_paste_rs("test uplink paste.rs provider").await;
        assert!(res.is_ok(), "paste.rs failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://paste.rs/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_text_0x0() {
        let res = upload_text_0x0("test uplink 0x0 provider").await;
        assert!(res.is_ok(), "0x0.st failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://0x0.st/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_catbox() {
        let res = upload_file_catbox("test.txt", b"hello catbox").await;
        assert!(res.is_ok(), "catbox.moe failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://files.catbox.moe/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_0x0() {
        let res = upload_file_0x0("test.txt", b"hello 0x0").await;
        assert!(res.is_ok(), "0x0.st failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://0x0.st/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_uguu() {
        let res = upload_file_uguu("test.txt", b"hello uguu").await;
        assert!(res.is_ok(), "uguu.se failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://a.uguu.se/"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_upload_file_pasteboard() {
        // Pasteboard might only accept image files, let's send a fake PNG or just try txt
        // Actually, pasteboard.co usually requires a valid image. Let's pass a small valid 1x1 PNG just in case!
        let tiny_png: [u8; 67] = [
            0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
            0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
            0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae,
            0x42, 0x60, 0x82
        ];
        let res = upload_file_pasteboard("test.png", &tiny_png).await;
        assert!(res.is_ok(), "pasteboard.co failed: {:?}", res);
        assert!(res.unwrap().starts_with("https://pasteboard.co/"));
    }
}
