{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "0.0.6";

  # Map Nix system to goreleaser's target naming
  targets = {
    "x86_64-linux" = "linux_amd64";
    "aarch64-linux" = "linux_arm64";
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-darwin" = "darwin_arm64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # SHA256 hashes for each platform
  hashes = {
    "linux_amd64" = "sha256-b6PGMpPqtlvbuSMoJW/UPX9EPyufCZVTMlbFFYB3jYs=";
    "linux_arm64" = "sha256-kwink8pX/Uu4IcqbHDd+0qa2d7m+5QEe6VrjVXDGQxU=";
    "darwin_amd64" = "sha256-FQ5OFbR7Gecf07K735RhExa0umBtuHmBoWJhVJIBGcs=";
    "darwin_arm64" = "sha256-TBZ0tIVwXRdEgO1oTh0vYMJJzrVBUXVCoONzBXYpIbw=";
  };

in
stdenv.mkDerivation {
  pname = "inbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mattrobenolt/inbox/releases/download/v${version}/inbox_${version}_${target}.tar.gz";
    hash = hashes.${target};
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 inbox $out/bin/inbox

    runHook postInstall
  '';

  meta = with lib; {
    description = "A fast, beautiful, and distraction-free Gmail client for your terminal";
    homepage = "https://github.com/mattrobenolt/inbox";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "inbox";
  };
}
