{ lib, stdenvNoCC, fetchurl }:

let
  version = "16.0.4";
  asset = {
    "x86_64-linux" = {
      name = "omp-linux-x64";
      hash = "sha256-lyh7k856bHgJgbE6OTsdI9iP+IHSUuKCtQzx55prpY4=";
    };
    "aarch64-linux" = {
      name = "omp-linux-arm64";
      hash = "sha256-AIgZb4GQbvL8Q4dgVC2pImQyCVgAq3btQH2GrEqB+78=";
    };
  }.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${asset.name}";
    hash = asset.hash;
  };

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  meta = with lib; {
    description = "AI coding agent CLI/TUI with 32 built-in tools, 40+ LLM providers, and sub-agent orchestration";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "omp";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
