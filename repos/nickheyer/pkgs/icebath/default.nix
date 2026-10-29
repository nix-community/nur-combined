{
  lib,
  fetchurl,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) system;
  assets = {
    x86_64-linux = {
      name = "icebath-linux-amd64";
      hash = "sha256-W61bvFlg4cNCoBWAPorKI/ZqaZFGhACfgsE6nblDS74=";
    };
    aarch64-linux = {
      name = "icebath-linux-arm64";
      hash = "sha256-sq8rDI9tHb5edHbGhokrkFs3AeT01wdAsFn2uY9SmhQ=";
    };
    x86_64-darwin = {
      name = "icebath-darwin-amd64";
      hash = "sha256-euEqLncJSeQwSjTmBvY22a+KHkjL6OlPw+tjJTPFS0w=";
    };
    aarch64-darwin = {
      name = "icebath-darwin-arm64";
      hash = "sha256-Dvx6cv5Ugf6mS0ZdUCINjdH6T3uHM/jyaQzQo0u9cp4=";
    };
  };
  asset = assets.${system};
in
stdenvNoCC.mkDerivation {
  pname = "icebath";
  version = "1.0.5";
  src = fetchurl {
    url = "https://github.com/nickheyer/icebath/releases/download/v1.0.5/${asset.name}";
    inherit (asset) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/icebath
    runHook postInstall
  '';

  meta = {
    description = "Tiling agentic harness and netrunner toolkit";
    homepage = "https://icebath.app";
    license = lib.licenses.mit;
    mainProgram = "icebath";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames assets;
  };
}
