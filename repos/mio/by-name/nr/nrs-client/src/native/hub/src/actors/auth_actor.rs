use crate::signals::{AuthStatusSignal, LoginRequest};
use rinf::{DartSignal, RustSignal};
use std::time::Duration;
use tokio::spawn;

pub struct AuthActor;

fn base64_encode(data: &[u8]) -> String {
    const CHARSET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut out = String::with_capacity((data.len() + 2) / 3 * 4);
    for chunk in data.chunks(3) {
        let b0 = chunk[0];
        let b1 = if chunk.len() > 1 { chunk[1] } else { 0 };
        let b2 = if chunk.len() > 2 { chunk[2] } else { 0 };
        out.push(CHARSET[(b0 >> 2) as usize] as char);
        out.push(CHARSET[(((b0 & 3) << 4) | (b1 >> 4)) as usize] as char);
        if chunk.len() > 1 {
            out.push(CHARSET[(((b1 & 0xF) << 2) | (b2 >> 6)) as usize] as char);
        } else {
            out.push('=');
        }
        if chunk.len() > 2 {
            out.push(CHARSET[(b2 & 0x3F) as usize] as char);
        } else {
            out.push('=');
        }
    }
    out
}

impl AuthActor {
    pub fn start() {
        spawn(async {
            let receiver = LoginRequest::get_dart_signal_receiver();
            while let Some(pack) = receiver.recv().await {
                let req = pack.message;
                Self::handle_login(req).await;
            }
        });
    }

    pub async fn authenticate(
        username: &str,
        password: &str,
        proxy_url: Option<&str>,
        country: Option<&str>,
    ) -> Result<(String, String, String, String), String> {
        let is_nz = country.map(|c| c.eq_ignore_ascii_case("NZ")).unwrap_or(false);

        if password.trim().is_empty() {
            return Err("Password cannot be empty".to_string());
        }

        let clean_user = if is_nz {
            let u = username.trim().to_string();
            if u.is_empty() {
                return Err("Please enter a valid email address or username".to_string());
            }
            u
        } else {
            let u: String = username.chars().filter(|c| c.is_ascii_digit()).collect();
            if u.is_empty() {
                return Err("Please enter a valid phone number".to_string());
            }
            u
        };

        let mut client_builder = reqwest::Client::builder()
            .timeout(Duration::from_secs(15))
            .cookie_store(true);

        if let Some(proxy) = proxy_url {
            if !proxy.trim().is_empty() {
                if let Ok(p) = reqwest::Proxy::all(proxy) {
                    client_builder = client_builder.proxy(p);
                }
            }
        }

        let client = client_builder
            .build()
            .map_err(|e| format!("Failed to create HTTP client: {}", e))?;

        let timestamp = chrono::Local::now().timestamp_millis();

        let (login_url, payload, use_basic_auth) = if is_nz {
            let enc_password = base64_encode(password.as_bytes());
            let pl = serde_json::json!({
                "userName": clean_user,
                "password": enc_password,
                "requestGateway": "2",
                "duplicateRequest": "false",
                "requestIdentificationNumber": timestamp,
                "deviceData": {
                    "appName": "TRS",
                    "appVersion": "1.0",
                    "browserVersion": "128.0",
                    "browser": "Firefox",
                    "osType": "Mac",
                    "osVersion": "15.0"
                }
            });
            ("https://www.nzrelay.co.nz/trsapi/services/rest/user/login", pl, true)
        } else {
            let enc_password = format!("{{ENC}}{}", base64_encode(password.as_bytes()));
            let pl = serde_json::json!({
                "userName": clean_user,
                "password": enc_password,
                "loginType": "4",
                "duplicateRequest": "false",
                "requestIdentificationNumber": timestamp,
                "deviceData": {
                    "appName": "NRS",
                    "appVersion": "1.0",
                    "browserVersion": "128.0",
                    "browser": "Firefox",
                    "osType": "Mac",
                    "osVersion": "15.0"
                }
            });
            ("https://nrschat.nrscall.gov.au/nrsapi/services/rest/user/login", pl, false)
        };

        let mut req_builder = client
            .post(login_url)
            .header("Content-Type", "application/json")
            .header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0");

        if use_basic_auth {
            req_builder = req_builder.header("Authorization", "Basic dHJzYXBpOlRyNUwxdjNAMjAyMQ==");
        }

        let resp = req_builder
            .json(&payload)
            .send()
            .await
            .map_err(|e| format!("Network request failed: {}", e))?;

        let text = resp
            .text()
            .await
            .map_err(|e| format!("Failed to read response body: {}", e))?;

        let val: serde_json::Value = serde_json::from_str(&text)
            .map_err(|e| format!("Invalid JSON response from gateway: {}", e))?;

        let status = val.get("status").and_then(|s| s.as_i64()).unwrap_or(-1);
        if status == 0 {
            if let Some(bean) = val.get("userContractBean") {
                let token = bean.get("id").and_then(|s| s.as_str()).unwrap_or("").to_string();
                let first_name = bean.get("firstName").and_then(|s| s.as_str()).unwrap_or("").to_string();
                let last_name = bean.get("lastName").and_then(|s| s.as_str()).unwrap_or("").to_string();
                let nrs_id = bean.get("nrsId")
                    .or_else(|| bean.get("preferredNumber"))
                    .or_else(|| bean.get("did"))
                    .and_then(|s| s.as_str())
                    .unwrap_or("")
                    .to_string();
                return Ok((token, first_name, last_name, nrs_id));
            }
            Err("Gateway responded with success but no userContractBean".to_string())
        } else {
            let mut err_msg = "Incorrect username or password".to_string();
            if let Some(arr) = val.get("keyValuePairs").and_then(|k| k.as_array()) {
                for item in arr {
                    if let Some(key) = item.get("key").and_then(|k| k.as_str()) {
                        if key == "ERROR_MSG" {
                            if let Some(v) = item.get("value").and_then(|v| v.as_str()) {
                                err_msg = v.to_string();
                                break;
                            }
                        }
                    }
                }
            }
            Err(err_msg)
        }
    }

    async fn handle_login(req: LoginRequest) {
        let is_nz = req.country.as_deref().map(|c| c.eq_ignore_ascii_case("NZ")).unwrap_or(false);
        let clean_user = if is_nz {
            req.username.trim().to_string()
        } else {
            req.username.chars().filter(|c| c.is_ascii_digit()).collect()
        };
        match Self::authenticate(&req.username, &req.password, req.proxy_url.as_deref(), req.country.as_deref()).await {
            Ok((token, first_name, last_name, nrs_id)) => {
                AuthStatusSignal {
                    is_authenticated: true,
                    username: clean_user,
                    user_token: token,
                    first_name,
                    last_name,
                    nrs_id,
                    error_message: None,
                }
                .send_signal_to_dart();
            }
            Err(err) => {
                AuthStatusSignal {
                    is_authenticated: false,
                    username: clean_user,
                    user_token: "".to_string(),
                    first_name: "".to_string(),
                    last_name: "".to_string(),
                    nrs_id: "".to_string(),
                    error_message: Some(err),
                }
                .send_signal_to_dart();
            }
        }
    }
}
