args@{
  lib,
  nixpkgs,
  sources,
  source-src ? sources.hmcl-dev-src,
  source-bin ? sources.hmcl-dev-bin,
  ...
}:
(nixpkgs.hmcl.override (lib.removeAttrs args [
  "lib"
  "nixpkgs"
  "sources"
  "source-src"
  "source-bin"
])).overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "hmcl-dev";
    inherit (source-bin) version src;

    terracottaBundleJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/TerracottaBundle.java";
    macOSProviderJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/provider/MacOSProvider.java";
  }
)
