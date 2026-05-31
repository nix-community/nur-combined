{
  lib,
  stdenv,
  fetchurl,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  targets = {
    "x86_64-linux" = "linux_amd64";
    "aarch64-linux" = "linux_arm64";
    "aarch64-darwin" = "darwin_arm64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "txtar";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mattrobenolt/txtar/releases/download/v${version}/txtar_${version}_${target}.tar.gz";
    hash = hashes.${target} or (throw "Missing txtar hash for target ${target}");
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 txtar $out/bin/txtar

    runHook postInstall
  '';

  meta = with lib; {
    description = "Go-style txtar archive tool";
    homepage = "https://github.com/mattrobenolt/txtar";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "txtar";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
