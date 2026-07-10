{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.1.5";

  sources = {
    aarch64-darwin = {
      asset = "ax-darwin-arm64";
      hash = "sha256-qamolfFN2nRDhAKEA8MsWsQ3vEsuEkaQqeNelKwp5+4=";
    };
    x86_64-darwin = {
      asset = "ax-darwin-x64";
      hash = "sha256-0UcsQ9SXBTMvrSZAgcAXaEf0Y0y1XofeAIOxRp0qIvg=";
    };
    x86_64-linux = {
      asset = "ax-linux-x64";
      hash = "sha256-T4/GRF9kg2xrWUKQ96XZAO5X/n8fmbI4Fyubg6oyMxc=";
    };
    aarch64-linux = {
      asset = "ax-linux-arm64";
      hash = "sha256-oofQkR84+5RAkLymU4k7YUIy/ipMKlXilwFCwHCSHFY=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "ax: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "ax";
  inherit version;

  src = fetchurl {
    url = "https://github.com/yusukebe/ax/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/ax

    runHook postInstall
  '';

  meta = {
    description = "The AI-era curl";
    homepage = "https://github.com/yusukebe/ax";
    license = lib.licenses.mit;
    mainProgram = "ax";
    platforms = builtins.attrNames sources;
  };
}
