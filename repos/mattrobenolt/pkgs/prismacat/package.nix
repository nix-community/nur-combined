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
  pname = "prismacat";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mattrobenolt/prismacat/releases/download/v${version}/prismacat_${version}_${target}.tar.gz";
    hash = hashes.${target} or (throw "Missing prismacat hash for target ${target}");
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 prismacat $out/bin/prismacat

    runHook postInstall
  '';

  meta = with lib; {
    description = "A cat clone with Prism syntax highlighting";
    homepage = "https://github.com/mattrobenolt/prismacat";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "prismacat";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
