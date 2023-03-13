{ lib
, stdenvNoCC
, fetchFromGitHub
, bash
}:

stdenvNoCC.mkDerivation rec
{
  pname = "thumbfast";
  version = "unstable-2022-11-16";

  src = fetchFromGitHub {
    owner = "po5";
    repo = "thumbfast";
    rev = "08d81035bb5020f4caa326e642341f2e8af00ffe";
    hash = "sha256-T+9RxkKWX6vwDNi8i3Yq9QXSJQNwsHD2mXOllaFuSyQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    install -Dm644 thumbfast.lua $out/share/mpv/scripts
    runHook postInstall
  '';

  postPatch = ''
    substituteInPlace thumbfast.lua \
      --replace '#!/bin/bash' '#!${bash}/bin/bash'
  '';

  passthru.scriptName = "thumbfast.lua";

  meta = with lib; {
    description = "High-performance on-the-fly thumbnailer for mpv";
    homepage = "https://github.com/po5/thumbfast";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ lunik1 ];
  };
}
