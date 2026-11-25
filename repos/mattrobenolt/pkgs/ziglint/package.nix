{
  lib,
  stdenv,
  fetchurl,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  assets = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "aarch64-darwin" = "macos-arm64";
  };

  asset =
    assets.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "ziglint";
  inherit version;

  src = fetchurl {
    url = "https://github.com/baskingspot/ziglint/releases/download/v${version}/ziglint-v${version}-${asset}.tar.gz";
    hash = hashes.${asset};
  };

  sourceRoot = "ziglint-v${version}-${asset}";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 ziglint $out/bin/ziglint

    runHook postInstall
  '';

  meta = with lib; {
    description = "An opinionated linter for Zig";
    homepage = "https://github.com/baskingspot/ziglint";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "ziglint";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
