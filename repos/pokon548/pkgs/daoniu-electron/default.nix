{ stdenv, lib, fetchurl, appimageTools, makeWrapper, electron_25 }:

let electron = electron_25;
in stdenv.mkDerivation rec {
  pname = "daoniu-electron";
  version = "1.0.0";

  src = fetchurl {
    url =
      "https://github.com/pokon548/daoniu-electron/releases/download/v${version}/daoniu-electron-${version}.AppImage";
    sha256 = "sha256-ODI6yI3LTFUXEjMyXOonJ5wGuB6kA1U6hfs98c16YzA=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/icons/hicolor/512x512

    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/daoniu-electron.desktop $out/share/applications/${pname}.desktop
    #cp -a ${appimageContents}/usr/share/icons/hicolor/512x512/apps $out/share/icons/hicolor/512x512

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    description = "Zhixi unofficial client for Linux";
    homepage = "https://github.com/pokon548/daoniu-electron";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
