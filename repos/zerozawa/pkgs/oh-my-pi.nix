{ lib, stdenvNoCC, fetchurl, makeWrapper, nodejs, python3 }:

let
  version = "15.12.3";
  asset = {
    "x86_64-linux" = {
      name = "omp-linux-x64";
      hash = "sha256-UJS7H7fkBtiRNuSUSN6Yrp6cBf6xBmo5si00BgLTF90=";
    };
    "aarch64-linux" = {
      name = "omp-linux-arm64";
      hash = "sha256-1kxs0m9zb4f86fhabnwwkyl79zw2zc0d6g2i2wmvxv2grn6dcd86=";
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

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/omp \
      --prefix PATH : ${lib.makeBinPath [ nodejs python3 ]} \
      --set npm_config_nodedir "${nodejs}"
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
