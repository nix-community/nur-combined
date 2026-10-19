{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
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
  }