{
  lib,
  stdenv,
  fetchurl,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  targets = {
    "x86_64-linux" = "x86_64-linux";
    "aarch64-linux" = "aarch64-linux";
    "aarch64-darwin" = "aarch64-macos";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "ziglint";
  inherit version;

  src = fetchurl {
    url = "https://github.com/rockorager/ziglint/releases/download/v${version}/ziglint-${target}.tar.gz";
    hash = hashes.${target} or (throw "Missing ziglint hash for target ${target}");
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
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
