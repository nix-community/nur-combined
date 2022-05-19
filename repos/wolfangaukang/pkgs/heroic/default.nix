{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, nodePackages
, electron
, gogdl
, legendary-gl
}:

let
  inherit (nodePackages) asar;

in stdenv.mkDerivation rec {
  pname = "heroic";
  version = "2.3.1";

  src = fetchurl {
    url = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v${version}/heroic_${version}_amd64.deb";
    sha256 = "sha256-GU7GEySMjwkIHGIQpZ3M8HWchpKHjpAb169+wZIaK6w=";
  };

  nativeBuildInputs = [
    asar
    dpkg
    makeWrapper
    gogdl
    legendary-gl
  ];

  unpackCmd = "dpkg -x $curSrc source";

  buildPhase = ''
    runHook preBuild

    # Patching constants to use gogdl and legendary-gl paths on /nix/store
    asar extract opt/Heroic/resources/app.asar "$TMP/work"
    substituteInPlace $TMP/work/build/constants.js \
      --replace "return '/bin/bash'" "return '${stdenv.shell}'"
    substituteInPlace $TMP/work/build/tools.js \
      --replace "return '/bin/bash'" "return '${stdenv.shell}'"
    asar pack --unpack='{*.node,*.ftz,rect-overlay}' "$TMP/work" opt/Heroic/resources/app.asar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out

    # Replacing binaries at app.asar.unpacked as a fallback
    rm -rf $out/opt/Heroic/resources/app.asar.unpacked/build/bin/linux/*
    cp ${legendary-gl}/bin/legendary ${gogdl}/bin/gogdl $out/opt/Heroic/resources/app.asar.unpacked/build/bin/linux/

    makeWrapper ${electron}/bin/electron $out/bin/heroic \
      --add-flags $out/opt/Heroic/resources/app.asar

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Native GUI Epic Games Launcher for Linux, Windows and Mac";
    homepage = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = [ "x86_64-linux" ];
  };
}
