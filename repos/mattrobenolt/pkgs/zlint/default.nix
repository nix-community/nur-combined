{ lib
, stdenv
, fetchurl
}:

let
  version = "0.7.9";

  # Map Nix system to zlint's target naming
  targets = {
    "x86_64-linux" = "linux-x86_64";
    "aarch64-linux" = "linux-aarch64";
    "x86_64-darwin" = "macos-x86_64";
    "aarch64-darwin" = "macos-aarch64";
  };

  target = targets.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # SHA256 hashes for each platform
  hashes = {
    "linux-x86_64" = "sha256-OIxQG/uP/g5P+1rGM7ccG3TkRloNHPjLLyP5mwgpmik=";
    "linux-aarch64" = "sha256-+3MZHGgKyTA2BbqKBZdPBoJ8mA6lkzFqvACTTGvRf68=";
    "macos-x86_64" = "sha256-crmr6tFovV1wom3h2hk6SV8u8kO+gLAuQd/r2vtTRc8=";
    "macos-aarch64" = "sha256-OeSfH7oP+mNggqMXwpcNHF+k1ds90FlWn7yVyAh4jx8=";
  };

in
stdenv.mkDerivation {
  pname = "zlint";
  inherit version;

  src = fetchurl {
    url = "https://github.com/DonIsaac/zlint/releases/download/v${version}/zlint-${target}";
    hash = hashes.${target};
  };

  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 $src $out/bin/zlint

    runHook postInstall
  '';

  meta = with lib; {
    description = "A linter for the Zig programming language";
    homepage = "https://github.com/DonIsaac/zlint";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    maintainers = [ ];
    mainProgram = "zlint";
  };
}
