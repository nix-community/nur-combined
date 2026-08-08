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
