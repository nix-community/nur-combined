{ stdenv
, fetchurl
, lib
, callPackage
, recurseIntoAttrs
, ...
} @ args:

lib.mapAttrs
  (k: v: recurseIntoAttrs {
    jdk = callPackage
      (import ./jdk-linux-base.nix {
        isJDK = true;
        sources = v.jdk;
      })
      { };
    jre = callPackage
      (import ./jdk-linux-base.nix {
        isJDK = false;
        sources = v.jre;
      })
      { };
  })
  (lib.importJSON ./sources.json)
