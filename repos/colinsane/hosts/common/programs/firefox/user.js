// DEFAULT OPTION VALUES: <https://searchfox.org/mozilla-central/source/modules/libpref/init/all.js>
// common tweaks: <https://librewolf.net/docs/settings/>
// runtime-modified prefs are stored in ~/.mozilla/firefox/default/prefs.js
//
// pref overriding is documented lightly here:
// - <https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig>
//
// use `pref(...)` to force a preference
// use `defaultPref(...)` to allow runtime reconfiguration
// use `lockPref(...)` to prevent the preferences from being changed at runtime (incl preventing firefox from updating them itself)
// discover preference names via the `about:config` page
// N.B.: supported option values appear to be:
// - string
// - bool
// - number
// anything else (e.g. arrays, objects) MUST be represented as strings (use backticks for multiline/raw strings)

// COMMON SETTINGS TO TOGGLE (at runtime, in about:config)
// defaultPref("security.ssl.require_safe_negotiation", false);

///// RESET UNWANTED ARKENFOX CHANGES
// browser.sessionstore.privacy_level: 0, 1, 2
// 0: persist partially-filled forms to disk, across browser restarts
defaultPref("browser.sessionstore.privacy_level", 0);
//
// `enable_0rtt_data=true`: enable 0-round-trip TLS resumption, at the expense that MITM can replay the client's first packet.
// defaultPref("security.tls.enable_0rtt_data", true);
//
// `require_safe_negotiation=false`: allow TLS 1.2 connections even to servers potentially vulnerable to CVE-2009-3555.
// this allows a MITM attacker to prefix arbitrary data to my request.
// as of 2025-07-20: 99.9% of sites support safe negotiation. 0.1% do not;
//                   google-chrome, epiphany, and stock firefox (not arkenfox) do not enforce safe negotiation.
// - <https://lwn.net/Articles/362234/>
// defaultPref("security.ssl.require_safe_negotiation", false);
//
// OCSP queries SSL cert revocation status on every connect; that means letting a 3rd party know every site you visit.
// disable that, how in hell is that good for privacy.
// N.B.: i'm pretty sure this keeps CRlite enabled, which is the better implementation of cert revocation (i.e. performed locally).
// see: <https://blog.mozilla.org/security/2020/01/09/crlite-part-1-all-web-pki-revocations-compressed/>
defaultPref("security.OCSP.enabled", 0);
//
// `security.OCSP.require=false`: if we can't query the revocation status of a SSL cert because
// the issuer is offline, treat it as unrevoked.
// see: <https://librewolf.net/docs/faq/#im-getting-sec_error_ocsp_server_error-what-can-i-do>
defaultPref("security.OCSP.require", false);
defaultPref("browser.display.use_system_colors", true);
// i think this is the thing which greys out download buttons for N milliseconds
defaultPref("security.dialog_enable_delay", 0);

// DISABLE DNS OVER HTTPS; use the system resolver.
defaultPref("network.trr.mode", 5);

// enable webGL
defaultPref("webgl.disabled", false);

// use the system PDF viewer: it's there for a reason
defaultPref("pdfjs.disabled", true);

// scrollbar configuration, see: <https://artemis.sh/2023/10/12/scrollbars.html>
// style=4 gives rectangular scrollbars
// could also enable "always show scrollbars" in about:preferences -- not sure what the actual pref name for that is
// note that too-large scrollbars (like 50px wide, even 20px) tend to obscure content (and make buttons unclickable)
defaultPref("widget.non-native-theme.scrollbar.size.override", 14);
defaultPref("widget.non-native-theme.scrollbar.style", 4);

// disable inertial/kinetic/momentum scrolling because it just gets in the way on touchpads
// source: <https://kparal.wordpress.com/2019/10/31/disabling-kinetic-scrolling-in-firefox/>
defaultPref("apz.gtk.kinetic_scroll.enabled", false);

// uidensity=2 gives more padding around UI elements.
// source: <https://codeberg.org/user0/Mobile-Friendly-Firefox>
defaultPref("browser.uidensity", 2);
// layout.css.devPixelsPerPx: acts as a global scale (even for the chrome)
// defaultPref("layout.css.devPixelsPerPx", 1.5);

// open external URIs/files via xdg-desktop-portal.
defaultPref("widget.use-xdg-desktop-portal.mime-handler", 1);
defaultPref("widget.use-xdg-desktop-portal.open-uri", 1);

defaultPref("browser.toolbars.bookmarks.visibility", "never");

// enable vertical tab view, like Sidebery (but loses the top-window horizontal tabs)
// defaultPref("browser.toolbarbuttons.introduced.sidebar-button", true);
defaultPref("sidebar.animation.enabled", false);
defaultPref("sidebar.backupState", `{"width":"","command":"","expanded":true,"hidden":false}`);
defaultPref("sidebar.main.tools", "history");
defaultPref("sidebar.revamp", true);
defaultPref("sidebar.verticalTabs", true);
// vvv default is for tabs button to toggle tab icons v.s. tab icons + description.
//    "hide-sidebar"  => toggle between tab icons + description and NO visibility at all.
defaultPref("sidebar.visibility", "hide-sidebar");

// configure topbar:
// placing an item in "seen" marks it as handled; items omitted from "seen" are placed in their default location.
// XXX(2024-12-01): the first "sidebar-button" placement is eaten. you MUST specify it at least twice for FF to respect it.
defaultPref("browser.uiCustomization.state", `{
  "placements":{
    "unified-extensions-area": ["browserpass_maximbaz_com-browser-action","ublock0_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","magnolia_12_34-browser-action"],
    "nav-bar":["firefox-view-button","sidebar-button","sidebar-button","stop-reload-button","back-button","forward-button","urlbar-container","unified-extensions-button","downloads-button"]
  },
  "currentVersion":20
}`);
// defaultPref("browser.uiCustomization.horizontalTabstrip", `["firefox-view-button","tabbrowser-tabs"]`);
// 0 to hide the window close button
// 2 to show the window close button (default)
defaultPref("browser.tabs.inTitlebar", 0);

defaultPref("reader.font_size", 9);  // not the normal meaning of font size: these are discrete options with no gaps, like 1,2,3,...
defaultPref("reader.font_type", "serif");
defaultPref("reader.color_scheme", "custom");
defaultPref("reader.custom_colors.background", "#fff1e5");  //< mimic ft.com colors
defaultPref("reader.custom_colors.foreground", "#241f31");

// TODO: don't hardcode `colin`
defaultPref("browser.download.lastDir", "/home/colin/tmp");
// defaultPref("browser.download.autohideButton", false);  //< optional, to always show DL button

// auto-open specific URI schemes without prompting:
defaultPref("network.protocol-handler.external.xdg-open", true); // for firefox-xdg-open extension
defaultPref("network.protocol-handler.external.mpv", true); // for open-in-mpv extension
defaultPref("network.protocol-handler.external.element", true); // for Element matrix client
defaultPref("network.protocol-handler.external.matrix", true); // for Nheko matrix client
defaultPref("network.protocol-handler.external.slack", true); // for official Slack desktop app
defaultPref("network.protocol-handler.external.zoommtg", true); // for official zoom desktop app

// statically configure bookmarks.
// notably, these bookmarks have "shortcut url" fields:
// - type `w thing` into the URL bar to search "thing" on Wikipedia.
// - to add a search shortcut: right-click any search box => "Add a keyword for this search".
// - to update the static bookmarks, export via Hamburger => bookmarks => manage bookmarks => Import and Backup => Export Bookmarks To HTML
defaultPref("browser.bookmarks.addedImportButton", true);
defaultPref("browser.places.importBookmarksHTML", true);
defaultPref("browser.bookmarks.file", "~/.mozilla/firefox/bookmarks.html");

defaultPref("browser.startup.homepage", "https://uninsane.org/places");

// silence the first-run "welcome to firefox"
defaultPref("trailhead.firstrun.didSeeAboutWelcome", true);

defaultPref("browser.aboutConfig.showWarning", false);
defaultPref("browser.shell.checkDefaultBrowser", false);

// disable extension updates
defaultPref("extensions.update.autoUpdateDefault", false);
defaultPref("extensions.update.enabled", false);
defaultPref("extensions.systemAddon.update.enabled", false);
// wipe the URIs used to check for updates, as a precaution.
defaultPref("extensions.update.url", "");
defaultPref("extensions.update.background.url", "");
defaultPref("extensions.systemAddon.update.url", "");

// also disable app-level auto-updates
defaultPref("app.update.auto", false);

// disable "safe browsing", in which my browser asks Google whether a site is malicious or not, for every site i visit (?)
defaultPref("browser.safebrowsing.blockedURIs.enabled", false);
defaultPref("browser.safebrowsing.downloads.enabled", false);
defaultPref("browser.safebrowsing.malware.enabled", false);
defaultPref("browser.safebrowsing.phishing.enabled", false);

// browser.engagement.sidebar-button.has-used
// browser.migration.version = 150

// allow sites to trigger desktop notifications, by default.
// i couldn't find a trivial way to plumb per-site permissions here -- probably kept in a separate db
defaultPref("permissions.default.desktop-notification", 1);
