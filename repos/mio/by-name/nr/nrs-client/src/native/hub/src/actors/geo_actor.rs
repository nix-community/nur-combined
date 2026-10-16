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
                Self::perform_check(req.proxy_url, req.country).await;
            }
        });
    }

    pub async fn perform_check(proxy_url: Option<String>, requested_country: Option<String>) {
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
                        country: requested_country.unwrap_or_else(|| "Unknown".to_string()),
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
                    country: requested_country.unwrap_or_else(|| "Unknown".to_string()),
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

        let geoip_country = ip_info
            .as_ref()
            .and_then(|v| v.get("country"))
            .and_then(|v| v.as_str())
            .unwrap_or("??")
            .to_uppercase();

        // 2. Determine target country (NZ or AU)
        let is_nz = match requested_country.as_deref() {
            Some("NZ") | Some("nz") => true,
            Some("AU") | Some("au") => false,
            _ => geoip_country == "NZ",
        };

        if is_nz {
            // Check NZ Relay Concentrix gateway
            let nz_res = client
                .get("https://omnicustomwebauc.concentrix.com/NZRelay/omnishell/prod/omniChatService.asmx/GetSessionId")
                .header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0")
                .send()
                .await;

            match nz_res {
                Ok(resp) => {
                    let status = resp.status();
                    if status.is_success() {
                        let st = if proxy_url.is_some() { "proxy_nz" } else { "direct_nz" };
                        GeoStatusSignal {
                            status: st.to_string(),
                            detected_ip,
                            country: "NZ".to_string(),
                            details: format!("Connected to NZ Relay successfully (Auckland gateway, HTTP {}). Ready for relay calls.", status.as_u16()),
                        }
                        .send_signal_to_dart();
                    } else {
                        GeoStatusSignal {
                            status: "error".to_string(),
                            detected_ip,
                            country: "NZ".to_string(),
                            details: format!("NZ Relay returned HTTP status: {}", status),
                        }
                        .send_signal_to_dart();
                    }
                }
                Err(e) => {
                    GeoStatusSignal {
                        status: "error".to_string(),
                        detected_ip,
                        country: "NZ".to_string(),
                        details: format!("Connection to NZ Relay gateway failed: {}", e),
                    }
                    .send_signal_to_dart();
                }
            }
        } else {
            // Check Australian NRS chat endpoint for GeoIP 302 redirection
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
                        let country_out = if geoip_country == "NZ" { "NZ".to_string() } else { "AU".to_string() };
                        GeoStatusSignal {
                            status: "geo_blocked".to_string(),
                            detected_ip,
                            country: country_out,
                            details: "Blocked by Australian GeoIP restriction (Redirected to geoinfo.html). Use NZ Relay or configure an Australian proxy.".to_string(),
                        }
                        .send_signal_to_dart();
                    } else if status.is_success() || status.is_redirection() {
                        let st = if proxy_url.is_some() { "proxy_au" } else { "direct_au" };
                        GeoStatusSignal {
                            status: st.to_string(),
                            detected_ip,
                            country: "AU".to_string(),
                            details: format!("Connected to NRS successfully (HTTP {}). Ready for relay calls.", status.as_u16()),
                        }
                        .send_signal_to_dart();
                    } else {
                        GeoStatusSignal {
                            status: "error".to_string(),
                            detected_ip,
                            country: "AU".to_string(),
                            details: format!("NRS returned unexpected HTTP status: {}", status),
                        }
                        .send_signal_to_dart();
                    }
                }
                Err(e) => {
                    GeoStatusSignal {
                        status: "error".to_string(),
                        detected_ip,
                        country: "AU".to_string(),
                        details: format!("Connection to NRS gateway failed: {}", e),
                    }
                    .send_signal_to_dart();
                }
            }
        }
    }
}
