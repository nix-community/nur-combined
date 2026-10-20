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

      regionUtilsJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/util/RegionUtils.java";
      regionUtilsJavaPath = "HMCL/src/main/java/org/jackhuang/hmcl/util/RegionUtils.java";

      prePatch = prevAttrs.prePatch + ''
        install -Dm644 "$regionUtilsJava" "$regionUtilsJavaPath"
      '';

      patches = prevAttrs.patches ++ [
        ./0003-nix-keep-downloads-enabled.patch
      ];

      preBuild = (prevAttrs.preBuild or "") + ''
        mkdir -p out
        javac -cp "$src" \
          -sourcepath "${source-src.src}/HMCLCore/src/main/java" \
          -implicit:none -d out "$regionUtilsJavaPath"
      '';

      runtimeDeps = prevAttrs.runtimeDeps ++ [ sdl3 ];
    }
  )
