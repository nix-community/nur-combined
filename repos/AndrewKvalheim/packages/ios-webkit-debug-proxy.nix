{ lib
, fetchFromGitHub
, stdenv

  # Dependencies
, autoreconfHook
, libimobiledevice
, libplist
, openssl
, pkg-config
}:

let
  inherit (builtins) toFile;

  libimobiledeviceWithOpenssl = libimobiledevice.overrideAttrs (l: {
    nativeBuildInputs = l.nativeBuildInputs ++ [ openssl ];
    configureFlags = lib.remove "--disable-openssl" l.configureFlags;
  });
in
stdenv.mkDerivation {
  pname = "ios-webkit-debug-proxy";
  version = "1.8.8-unstable-2021-08-12";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ios-webkit-debug-proxy";
    rev = "d33433dfce4edb024ce34573fa64f80c80a1676e";
    hash = "sha256-YzjMKf+mudGbiBwDDxy5YE5CkQcePjgo7eouMIgw7J4=";
  };

  patches = [ (toFile "fixup-697dbc5.patch" ''
    --- a/src/device_listener.c
    +++ b/src/device_listener.c
    @@ -32 +32 @@
    -#include "device_listener.h"
    +#include "ios-webkit-debug-proxy/device_listener.h"
    --- a/src/socket_manager.c
    +++ b/src/socket_manager.c
    @@ -34 +34 @@
    -#include "socket_manager.h"
    +#include "ios-webkit-debug-proxy/socket_manager.h"
    --- a/src/webinspector.c
    +++ b/src/webinspector.c
    @@ -33 +33 @@
    -#include "webinspector.h"
    +#include "ios-webkit-debug-proxy/webinspector.h"
    --- a/src/websocket.c
    +++ b/src/websocket.c
    @@ -15 +15 @@
    -#include "websocket.h"
    +#include "ios-webkit-debug-proxy/websocket.h"
  '') ];

  nativeBuildInputs = [
    autoreconfHook
    libimobiledeviceWithOpenssl
    libplist
    openssl
    pkg-config
  ];

  meta = {
    description = "DevTools proxy (Chrome Remote Debugging Protocol) for iOS devices (Safari Remote Web Inspector)";
    homepage = "https://github.com/google/ios-webkit-debug-proxy";
    license = lib.licenses.bsd3;
  };
}
