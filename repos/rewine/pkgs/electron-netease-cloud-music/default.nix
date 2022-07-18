{ lib
, stdenv
, fetchurl
, makeDesktopItem
, copyDesktopItems
, electron
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "electron-netease-cloud-music";
  version = "0.9.34";

  src = fetchurl {
    url = "https://github.com/Rocket1184/${pname}/releases/download/v${version}/${pname}_v${version}.asar";
    sha256 = "sha256-8yX4VJ/QfAnXaSNPmxN9AquRuvJ/YU+L8kb/z/rEGG0=";
  };

  desktopItems = [
    (makeDesktopItem rec {
      name = "ElectronNCM";
      exec = pname;
      icon = pname;
      comment = meta.description;
      desktopName = name;
      genericName = pname;
      categories = [ "AudioVideo" "Player" ];
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];
  
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -D $src $out/opt/${pname}_v${version}.asar
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/opt/${pname}_v${version}.asar

    runHook postInstall
  '';

  meta = with lib; {
    description = "UNOFFICIAL client for music.163.com. Powered by Electron and Vue
";
    homepage = "https://ncm-releases.herokuapp.com";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}

