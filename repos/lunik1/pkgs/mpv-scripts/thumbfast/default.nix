{ lib
, stdenvNoCC
, fetchFromGitHub
, bash
}:

stdenvNoCC.mkDerivation rec
{
  pname = "thumbfast";
  version = "unstable-2023-09-08";

  src = fetchFromGitHub {
    owner = "l-jared";
    repo = "thumbfast";
    rev = "03f0dddf4c784a0fc6f127b305258a398dd3f8b8";
    hash = "sha256-Ozli4XBZxzsrxJw3EPKYCCFIGcS94vU9ZWp2UNPVFNA=";
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
    license = licenses.mpl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ lunik1 ];
  };
}
