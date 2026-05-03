{
  upstream,
  sources,
  source-src ? sources.hmcl-dev-src,
  source-bin ? sources.hmcl-dev-bin,
}:
upstream.hmcl.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "hmcl-dev";
    inherit (source-bin) version src;

    terracottaBundleJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/TerracottaBundle.java";
    macOSProviderJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/provider/MacOSProvider.java";
  }
)
