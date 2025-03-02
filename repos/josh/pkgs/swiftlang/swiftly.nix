# Upstream to NixOS/nixpkgs
# - Needs to build from source rather than install binaries.
#   - Blocked on NixOS/nixpkgs supporting Swift 6.0
# - Waiting for v0.3.0+ to be released
#   - Adds `swiftly init`
#   - Adds macOS support
#
{
  lib,
  stdenv,
  stdenvNoCC,
  runCommand,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:
let
  version = "0.3.0";
  sources = {
    "aarch64-linux" = fetchurl {
      url = "https://github.com/swiftlang/swiftly/releases/download/0.3.0/swiftly-aarch64-unknown-linux-gnu";
      sha256 = "0g7xi094h9jk90qa7d9ya1vp16l6rn4m3wrazd42bz5fwirp7z5h";
    };
    "x86_64-linux" = fetchurl {
      url = "https://github.com/swiftlang/swiftly/releases/download/0.3.0/swiftly-x86_64-unknown-linux-gnu";
      sha256 = "1gll8rq5qrs4wblk8vds9wcfkva0sdmp88kpj2dwvxwjc04x680q";
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "swiftly";
  inherit version;
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
    mkdir -p "$out/bin" "$out/share/swiftly"
    cp "$src" "$out/bin/swiftly"
    chmod +x "$out/bin/swiftly"
  '';

  passthru.tests = {
    version =
      runCommand "test-swiftly-version"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          swiftly --version
          touch $out
        '';

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
    description = "A Swift toolchain installer and manager, written in Swift";
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
