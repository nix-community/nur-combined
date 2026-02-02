{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "0.5.0";

  # Map Nix system to ziglint's target naming
  targets = {
    "x86_64-linux" = "x86_64-linux";
    "aarch64-linux" = "aarch64-linux";
    "aarch64-darwin" = "aarch64-macos";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # SHA256 hashes for each platform
  hashes = {
    "x86_64-linux" = "sha256-I8WUg4ZEgAtYY1X0LuVF+4CcmAeK34H8nJQ39HB47IQ=";
    "aarch64-linux" = "sha256-2qhmCX3LtM3tjUtiLWltA7Vu+Jk2W+dsuGUY8gFyQ/w=";
    "aarch64-macos" = "sha256-Z5PzyUAgv1z/PRPaABVd9JBGY/tYwxO4AdCkSsO8sZc=";
  };

in
stdenv.mkDerivation {
  pname = "ziglint";
  inherit version;

  src = fetchurl {
    url = "https://github.com/rockorager/ziglint/releases/download/v${version}/ziglint-${target}.tar.gz";
    hash = hashes.${target};
  };

  sourceRoot = ".";

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
    homepage = "https://github.com/rockorager/ziglint";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "ziglint";
  };
}
