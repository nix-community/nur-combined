# Upstream to NixOS/nixpkgs
# - Needs to build from source rather than install binaries.
#   - Blocked on NixOS/nixpkgs supporting Swift 6.0
#
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,

  autoPatchelfHook,
  zlib,

  runCommand,
  testers,
}:
let
  version = "0.3.0";
  sources = {
    "aarch64-linux" = fetchurl {
      url = "https://github.com/swiftlang/swiftly/releases/download/${version}/swiftly-aarch64-unknown-linux-gnu";
      hash = "sha256-sPxzc+Su/CVI+yrzUYnNhppwd1A+taMwSFMmSBKI/Tw=";
    };
    "x86_64-linux" = fetchurl {
      url = "https://github.com/swiftlang/swiftly/releases/download/${version}/swiftly-x86_64-unknown-linux-gnu";
      hash = "sha256-GCDTCWCS982bkHcidGvTQO3pGE+6bTTp4kRnXHBGlL4=";
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "swiftly";
  inherit version;

  __structuredAttrs = true;

  src = sources.${stdenvNoCC.hostPlatform.system};

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "$src" "$out/bin/swiftly"
    chmod +x "$out/bin/swiftly"

    runHook postInstall
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-swiftly-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          swiftly --help
          touch $out
        '';
  };

  meta = {
    description = "Swift toolchain installer and manager, written in Swift";
    longDescription = ''
      swiftly is a CLI tool for installing, managing, and switching between Swift toolchains, written in Swift.
    '';
    homepage = "https://github.com/swiftlang/swiftly";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "swiftly";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
