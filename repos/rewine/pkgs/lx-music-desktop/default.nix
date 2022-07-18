{ lib
, stdenv
, fetchurl
, electron
, appimageTools
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "lx-music-desktop";
  version = "1.22.0";

  src = fetchurl {
    url = "https://github.com/lyswhut/lx-music-desktop/releases/download/v${version}/lx-music-desktop-v${version}-x64.AppImage";
    sha256 = "sha256-+AedYjmUNP5ltGw7jHWRlHogE7PiQARhAvZPGTtgtnc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share $out/share/applications

    cp -a ${appimageContents}/{locales,resources} $out/share/
    cp -a ${appimageContents}/${pname}.desktop $out/share/applications/
    cp -a ${appimageContents}/usr/share/icons $out/share/

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    homepage = "https://lxmusic.toside.cn";
    description = "luoxu music player powered by electron";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}

