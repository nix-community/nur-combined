// begin
/*** [SECTION 0700]: DNS / DoH / PROXY / SOCKS / IPv6 ***/
lockPref("network.trr.mode", 0); // explicitly off
lockPref("network.proxy.no_proxies_on", "localhost,127.0.0.1,192.168.0.0/16");
/*** [SECTION 1200]: HTTPS (SSL/TLS / OCSP / CERTS / HPKP) ***/
lockPref("security.OCSP.require", false);
/*** [SECTION 2700]: ETP (ENHANCED TRACKING PROTECTION) ***/
lockPref("browser.contentblocking.category", "standard");
/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
lockPref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
lockPref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
/*** [SECTION 5000]: OPTIONAL OPSEC ***/
lockPref("signon.rememberSignons", false);
/*** [SECTION 9999]: OTHERS ***/
lockPref("browser.translations.automaticallyPopup", false);
// end
