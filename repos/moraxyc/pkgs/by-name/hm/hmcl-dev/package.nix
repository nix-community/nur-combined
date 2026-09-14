args@{
  lib,
  nixpkgs,
  sources,
  source-src ? sources.hmcl-dev-src,
  source-bin ? sources.hmcl-dev-bin,

  sdl3,
  ...
}:
(nixpkgs.hmcl.override (
  lib.removeAttrs args [
    "lib"
    "nixpkgs"
    "sources"
    "source-src"
    "source-bin"
    "sdl3"
  ]
)).overrideAttrs
  (
    finalAttrs: prevAttrs: {
      pname = "hmcl-dev";
      inherit (source-bin) version src;

      terracottaBundleJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/TerracottaBundle.java";
      macOSProviderJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/provider/MacOSProvider.java";

      runtimeDeps = prevAttrs.runtimeDeps ++ [ sdl3 ];
    }
  )
