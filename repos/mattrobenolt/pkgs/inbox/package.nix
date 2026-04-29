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
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-darwin" = "darwin_arm64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "inbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mattrobenolt/inbox/releases/download/v${version}/inbox_${version}_${target}.tar.gz";
    hash = hashes.${target} or (throw "Missing inbox hash for target ${target}");
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
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
