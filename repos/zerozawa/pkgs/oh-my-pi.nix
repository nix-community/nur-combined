{ lib, stdenvNoCC, fetchurl }:

let
  version = "16.0.5";
  asset = {
    "x86_64-linux" = {
      name = "omp-linux-x64";
      hash = "sha256-gamoR9iIK6wahclhOe0kXZYryxkJ8v8Tq65xIu3Z320=";
    };
    "aarch64-linux" = {
      name = "omp-linux-arm64";
      hash = "sha256-We/8CASGZxQv5rgCjoI2bVRdR83qqGsoZQ2BU0xOKTo=";
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
