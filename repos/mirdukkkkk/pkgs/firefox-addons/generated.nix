{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
    "cookie-editor" = buildMozillaXpiAddon {
      pname = "cookie-editor";
      version = "1.13.0";
      addonId = "{c3c10168-4186-445c-9c5b-63f12b8e2c87}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4241002/cookie_editor-1.13.0.xpi";
      sha256 = "3d6fd83a8343dfa5e4461d83c2856264fb74b36b1c165305168d013f4831dbb0";
      meta = with lib;
      {
        homepage = "https://cookie-editor.com/";
        description = "Cookie-Editor lets you efficiently create, edit and delete a cookie for the current tab. Perfect for developing, quickly testing or even manually managing your cookies for your privacy.";
        license = licenses.gpl3;
        mozPermissions = [ "cookies" "tabs" "storage" "devtools" ];
        platforms = platforms.all;
      };
    };
    "flagfox" = buildMozillaXpiAddon {
      pname = "flagfox";
      version = "6.2.6";
      addonId = "{1018e4d6-728f-4b20-ad56-37578a4de76b}";
      url = "https://addons.mozilla.org/firefox/downloads/file/5067561/flagfox-6.2.6.xpi";
      sha256 = "ffc955454fb32a50a8a6d994802337fcfa82198ccf9dfcded94085ca6a950742";
      meta = with lib;
      {
        homepage = "https://flagfox.wordpress.com/";
        description = "Displays a country flag depicting the location of the current website's server and provides a multitude of tools such as site safety checks, whois, translation, similar sites, validation, URL shortening, and more...";
        mozPermissions = [
          "storage"
          "clipboardRead"
          "clipboardWrite"
          "menus"
          "contextMenus"
          "notifications"
          "tabs"
          "webRequest"
          "dns"
          "cookies"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "indicatetls" = buildMozillaXpiAddon {
      pname = "indicatetls";
      version = "0.4.0";
      addonId = "{252ee273-8c8d-4609-b54d-62ae345be0a1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4756082/indicatetls-0.4.0.xpi";
      sha256 = "9c22d7e15e63583bb0062370152f6d3b781c5c3309bbd5017d2ae7ce88fca0f8";
      meta = with lib;
      {
        homepage = "https://github.com/jannispinter/indicatetls";
        description = "Displays negotiated SSL/TLS protocol version and additional security information in the address bar";
        license = licenses.mpl20;
        mozPermissions = [
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "plasma-integration" = buildMozillaXpiAddon {
      pname = "plasma-integration";
      version = "2.1";
      addonId = "plasma-browser-integration@kde.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4614817/plasma_integration-2.1.xpi";
      sha256 = "35bfa3766e097160e74f525bde54d97bbba90d725daa425b9de6fef6ec5e9d44";
      meta = with lib;
      {
        homepage = "http://kde.org";
        description = "Multitask efficiently by controlling browser functions from the Plasma desktop.";
        license = licenses.gpl3;
        mozPermissions = [
          "nativeMessaging"
          "notifications"
          "storage"
          "downloads"
          "tabs"
          "scripting"
          "contextMenus"
          "favicon"
          "history"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "preact-devtools" = buildMozillaXpiAddon {
      pname = "preact-devtools";
      version = "5.1.0";
      addonId = "devtools@marvinh.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/5065433/preact_devtools-5.1.0.xpi";
      sha256 = "7fae9d871ce4b6ba35864feee1bcb08ec02c93fc8b63f786d6858eacda5b1328";
      meta = with lib;
      {
        homepage = "https://github.com/preactjs/preact-devtools";
        description = "Only works with Preact 10.1.0 upwards\n\nDebugging tools for Preact. This extension allows you to inspect the component hierarchy and change properties on the fly.";
        license = licenses.mit;
        mozPermissions = [ "scripting" "storage" "devtools" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "reduxdevtools" = buildMozillaXpiAddon {
      pname = "reduxdevtools";
      version = "3.2.10";
      addonId = "extension@redux.devtools";
      url = "https://addons.mozilla.org/firefox/downloads/file/4467343/reduxdevtools-3.2.10.xpi";
      sha256 = "ef2b10a2bc8b0d1a844d146e3eeaff407eaaa63cd0564db8eafd870c87a88956";
      meta = with lib;
      {
        homepage = "https://github.com/reduxjs/redux-devtools";
        description = "DevTools for Redux with actions history, undo and replay.";
        license = licenses.mit;
        mozPermissions = [
          "notifications"
          "contextMenus"
          "tabs"
          "storage"
          "devtools"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "resourceoverride" = buildMozillaXpiAddon {
      pname = "resourceoverride";
      version = "1.3.2";
      addonId = "{9a253c57-0e95-4589-be64-365b3602c564}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3809866/resourceoverride-1.3.2.xpi";
      sha256 = "4ac22a14c92cd9bdf951b2a296888d262947736bc4f016e7ad7ad5964d466dab";
      meta = with lib;
      {
        homepage = "https://github.com/kylepaulsen/ResourceOverride";
        description = "An extension to help you gain full control of any website by redirecting traffic, replacing, editing, or inserting new content.";
        license = licenses.mit;
        mozPermissions = [
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "tabs"
          "devtools"
          "*://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "sponsorblock" = buildMozillaXpiAddon {
      pname = "sponsorblock";
      version = "6.1.7";
      addonId = "sponsorBlocker@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4897574/sponsorblock-6.1.7.xpi";
      sha256 = "0d50e1632c6f15ee15a543e670e1c572974605a5c02622916e08e026803df83f";
      meta = with lib;
      {
        homepage = "https://sponsor.ajay.app";
        description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos. Other browsers: https://sponsor.ajay.app";
        license = licenses.lgpl3;
        mozPermissions = [
          "storage"
          "scripting"
          "unlimitedStorage"
          "https://sponsor.ajay.app/*"
          "https://*.youtube.com/*"
          "https://www.youtube-nocookie.com/embed/*"
        ];
        platforms = platforms.all;
      };
    };
    "ublock-origin" = buildMozillaXpiAddon {
      pname = "ublock-origin";
      version = "1.75.0";
      addonId = "uBlock0@raymondhill.net";
      url = "https://addons.mozilla.org/firefox/downloads/file/5034826/ublock_origin-1.75.0.xpi";
      sha256 = "5b74415860456370644bd80f16125e865b0e6c356bb5dfcfb84069967eaa5287";
      meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        mozPermissions = [
          "alarms"
          "dns"
          "menus"
          "privacy"
          "storage"
          "tabs"
          "unlimitedStorage"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
          "file://*/*"
          "https://easylist.to/*"
          "https://*.fanboy.co.nz/*"
          "https://filterlists.com/*"
          "https://forums.lanik.us/*"
          "https://github.com/*"
          "https://*.github.io/*"
          "https://github.com/uBlockOrigin/*"
          "https://ublockorigin.github.io/*"
          "https://*.reddit.com/r/uBlockOrigin/*"
        ];
        platforms = platforms.all;
      };
    };
  }