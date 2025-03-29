// begin
/*** [SECTION 0700]: DNS / DoH / PROXY / SOCKS / IPv6 ***/
user_pref("network.trr.mode", 0); // explicitly off
user_pref("network.proxy.no_proxies_on", "localhost,127.0.0.1,192.168.0.0/16");
/*** [SECTION 1200]: HTTPS (SSL/TLS / OCSP / CERTS / HPKP) ***/
user_pref("security.OCSP.require", false);
/*** [SECTION 2700]: ETP (ENHANCED TRACKING PROTECTION) ***/
user_pref("browser.contentblocking.category", "standard");
/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
/*** [SECTION 5000]: OPTIONAL OPSEC ***/
user_pref("signon.rememberSignons", false);
/*** [SECTION 9999]: OTHERS ***/
user_pref("browser.translations.automaticallyPopup", false);
// end
