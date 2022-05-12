{ stdenv
, fetchurl
, lib
, callPackage
, ...
} @ args:

(lib.mapAttrs
  (k: v: {
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
  (lib.importJSON ./sources.json)) // {
  recurseForDerivations = true;
}
