{ lib
, stdenv
, fetchurl
, makeDesktopItem
, copyDesktopItems
, electron
, makeWrapper
}:
let
  pname = "electron-netease-cloud-music";
  version = "0.9.36";
  srcs = {
    asar = fetchurl {
      url = "https://github.com/Rocket1184/${pname}/releases/download/v${version}/${pname}_v${version}.asar";
      sha256 = "sha256-ElJKdI+yuvvjUtqEulyFHz3VvMKXgAbX9QXwRk1oQkg=";
    };
    icon = fetchurl {
      url = "https://raw.githubusercontents.com/Rocket1184/electron-netease-cloud-music/master/assets/icons/icon.svg";
      sha256 = "sha256-o4YeDsiNsqbGYO1VcvGzYKuZIMpvPSKvG5JkeSzFxUw=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = srcs.asar;

  desktopItems = [
    (makeDesktopItem rec {
      name = "ElectronNCM";
      exec = pname;
      icon = pname;
      comment = meta.description;
      desktopName = name;
      genericName = pname;
      categories = [ "AudioVideo" ];
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    mkdir -p $out/share/pixmaps

    cp $src $out/opt/${pname}_v${version}.asar
    cp ${srcs.icon} $out/share/pixmaps/${pname}.svg

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

