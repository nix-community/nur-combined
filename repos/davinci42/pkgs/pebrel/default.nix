{
  lib,
  stdenvNoCC,
  fetchurl,
  callPackage,
  nix-update-script,
}:
let
  sources = {
    x86_64-linux = {
      asset = "linux-x64-preview.tar.gz";
      hash = "sha256-OahYKigwrAZzcZLKN62axShVZ+pgdq10rOWVRdBtGd0=";
    };
    aarch64-darwin = {
      asset = "macos-arm64-preview.dmg";
      hash = "sha256-JljpcGQ95yJYzEg/DS8M2g8SUpj+OyhxztGw82VCyEs=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
  platformAttrs =
    removeAttrs
      (callPackage (if stdenvNoCC.hostPlatform.isDarwin then ./darwin.nix else ./linux.nix) { })
      [
        "override"
        "overrideDerivation"
      ];
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  platformAttrs
  // {
    pname = "pebrel";
    version = "2.2.2";

    src = fetchurl {
      url = "https://github.com/Kuddev/pebrel/releases/download/v${finalAttrs.version}/Pebrel-v${finalAttrs.version}-${source.asset}";
      inherit (source) hash;
    };

    dontBuild = true;
    dontStrip = true;

    passthru = {
      updateScript = nix-update-script {
        attrPath = "pebrel";
        extraArgs = [
          "-f"
          "."
          "--use-github-releases"
        ];
      };
      tests.packaging = callPackage ../../tests/pkgs/pebrel.nix {
        package = finalAttrs.finalPackage;
      };
    };

    meta = {
      description = "GPU-accelerated terminal and SSH workspace";
      homepage = "https://github.com/Kuddev/pebrel";
      license = lib.licenses.gpl3Plus;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = builtins.attrNames sources;
      mainProgram = "pebrel";
    };
  }
)
