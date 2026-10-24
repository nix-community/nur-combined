args@{
  lib,
  nixpkgs,
  sources,
  source-src ? sources.hmcl-dev-src,
  source-bin ? sources.hmcl-dev-bin,

  easytierDiscoveryNodes ? [ ],

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
    "easytierDiscoveryNodes"
    "sdl3"
  ]
)).overrideAttrs
  (
    finalAttrs: prevAttrs: {
      pname = "hmcl-dev";
      inherit (source-bin) version src;

      terracottaBundleJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/TerracottaBundle.java";
      macOSProviderJava = "${source-src.src}/HMCL/src/main/java/org/jackhuang/hmcl/terracotta/provider/MacOSProvider.java";

      regionUtilsJavaPath = "HMCL/src/main/java/org/jackhuang/hmcl/util/RegionUtils.java";
      terracottaNodeListJavaPath = "HMCL/src/main/java/org/jackhuang/hmcl/terracotta/TerracottaNodeList.java";

      prePatch = prevAttrs.prePatch + ''
        install -Dm644 "${source-src.src}/$regionUtilsJavaPath" "$regionUtilsJavaPath"
        install -Dm644 "${source-src.src}/$terracottaNodeListJavaPath" "$terracottaNodeListJavaPath"
      '';

      patches =
        prevAttrs.patches
        ++ [
          ./0003-nix-keep-downloads-enabled.patch
        ]
        ++ lib.optional (easytierDiscoveryNodes != [ ]) (
          nixpkgs.replaceVars ./0004-nix-add-easytier-nodes.patch {
            NODES = lib.concatMapStringsSep ", " builtins.toJSON easytierDiscoveryNodes;
          }
        );

      preBuild = (prevAttrs.preBuild or "") + ''
        mkdir -p out
        javac -cp "$src" \
          -sourcepath "${source-src.src}/HMCLCore/src/main/java" \
          -implicit:none -d out "$regionUtilsJavaPath"

        javac -cp "out:$src" \
          -sourcepath "${source-src.src}/HMCLCore/src/main/java" \
          -implicit:none -d out "$terracottaNodeListJavaPath"
      '';

      runtimeDeps = prevAttrs.runtimeDeps ++ [ sdl3 ];
    }
  )
