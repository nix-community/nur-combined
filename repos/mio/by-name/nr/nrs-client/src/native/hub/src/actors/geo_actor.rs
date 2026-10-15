use crate::signals::{CheckGeoStatusRequest, GeoStatusSignal};
use rinf::{DartSignal, RustSignal};
use std::time::Duration;
use tokio::spawn;

pub struct GeoActor;

impl GeoActor {
    pub fn start() {
        spawn(async {
            let receiver = CheckGeoStatusRequest::get_dart_signal_receiver();
            while let Some(signal_pack) = receiver.recv().await {
                let req = signal_pack.message;
                Self::perform_check(req.proxy_url).await;
            }
        });
    }

    pub async fn perform_check(proxy_url: Option<String>) {
        let mut client_builder = reqwest::Client::builder()
            .timeout(Duration::from_secs(8))
            .cookie_store(true)
            .redirect(reqwest::redirect::Policy::none());


        if let Some(ref proxy) = proxy_url {
            if !proxy.trim().is_empty() {
                if let Ok(p) = reqwest::Proxy::all(proxy) {
                    client_builder = client_builder.proxy(p);
                } else {
                    GeoStatusSignal {
                        status: "error".to_string(),
                        detected_ip: "N/A".to_string(),
                        country: "Unknown".to_string(),
                        details: format!("Invalid proxy URL format: {}", proxy),
                    }
                    .send_signal_to_dart();
                    return;
                }
            }
        }

        let client = match client_builder.build() {
            Ok(c) => c,
            Err(e) => {
                GeoStatusSignal {
                    status: "error".to_string(),
                    detected_ip: "N/A".to_string(),
                    country: "Unknown".to_string(),
                    details: format!("Failed to build HTTP client: {}", e),
                }
                .send_signal_to_dart();
                return;
            }
        };

        // 1. Check IP info
        let ip_info = match client.get("https://ipinfo.io/json").send().await {
            Ok(resp) => resp.json::<serde_json::Value>().await.ok(),
            Err(_) => None,
        };

        let detected_ip = ip_info
            .as_ref()
            .and_then(|v| v.get("ip"))
            .and_then(|v| v.as_str())
            .unwrap_or("Unknown")
            .to_string();

        let country = ip_info
            .as_ref()
            .and_then(|v| v.get("country"))
            .and_then(|v| v.as_str())
            .unwrap_or("??")
            .to_string();

        // 2. Check NRS chat endpoint for GeoIP 302 redirection
        let nrs_res = client
            .get("https://nrschat.nrscall.gov.au/nrs/internetrelay")
            .header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0")
            .send()
            .await;

        match nrs_res {
            Ok(resp) => {
                let status = resp.status();
                let loc = resp
                    .headers()
                    .get("location")
                    .and_then(|l| l.to_str().ok())
                    .unwrap_or("");

                if loc.contains("geoinfo.html") {
                    GeoStatusSignal {
                        status: "geo_blocked".to_string(),
                        detected_ip,
                        country,
                        details: "Blocked by Australian GeoIP restriction (Redirected to geoinfo.html). Please configure an Australian proxy or use simulator mode.".to_string(),
                    }
                    .send_signal_to_dart();
                } else if status.is_success() || status.is_redirection() {
                    let st = if proxy_url.is_some() { "proxy_au" } else { "direct_au" };
                    GeoStatusSignal {
                        status: st.to_string(),
                        detected_ip,
                        country,
                        details: format!("Connected to NRS successfully (HTTP {}). Ready for relay calls.", status.as_u16()),
                    }
                    .send_signal_to_dart();
                } else {
                    GeoStatusSignal {
                        status: "error".to_string(),
                        detected_ip,
                        country,
                        details: format!("NRS returned unexpected HTTP status: {}", status),
                    }
                    .send_signal_to_dart();
                }
            }
            Err(e) => {
                GeoStatusSignal {
                    status: "error".to_string(),
                    detected_ip,
                    country,
                    details: format!("Connection failed: {}", e),
                }
                .send_signal_to_dart();
            }
        }
    }
}
