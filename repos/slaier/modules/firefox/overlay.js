// begin
/*** [SECTION 0700]: DNS / DoH / PROXY / SOCKS / IPv6 ***/
user_pref("network.trr.mode", 0); // explicitly off
user_pref("network.proxy.no_proxies_on", "localhost,127.0.0.1,192.168.0.0/16");
/*** [SECTION 2700]: ETP (ENHANCED TRACKING PROTECTION) ***/
user_pref("browser.contentblocking.category", "standard");
/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
user_pref("privacy.clearOnShutdown.history", false);
/*** [SECTION 5000]: OPTIONAL OPSEC ***/
user_pref("signon.rememberSignons", false);
// end
