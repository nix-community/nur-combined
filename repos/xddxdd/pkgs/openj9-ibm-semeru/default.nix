{ stdenv
, fetchurl
, lib
, callPackage
, recurseIntoAttrs
, ...
} @ args:

let
  mapSources = f: lib.mapAttrs' f (lib.importJSON ./sources.json);
  callJdkPackage = args: callPackage (import ./jdk-linux-base.nix args) { };
in
(mapSources (k: v: lib.nameValuePair "jdk-bin-${k}"
  (callJdkPackage { isJDK = true; sources = v.jdk; })))
  //
(mapSources (k: v: lib.nameValuePair "jre-bin-${k}"
  (callJdkPackage { isJDK = false; sources = v.jre; })))
