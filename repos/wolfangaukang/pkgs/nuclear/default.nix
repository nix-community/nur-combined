{ lib
, stdenv
, fetchurl
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, electron
}:

stdenv.mkDerivation rec {
  pname = "nuclear";
  version = "unstable-2022-05-10";
  releaseCode = "2ec701";

  src = fetchurl {
    url = "https://github.com/nukeop/nuclear/releases/download/${releaseCode}/${pname}-${releaseCode}.tar.gz";
    sha256 = "sha256-qXhRr/1Hfmh+JNtKAH+QjrJTbj9Hps2I5uvEuAULJJw=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = "nuclear";
      icon = "nuclear";
      comment = meta.description;
      desktopName = "Nuclear";
      genericName = "Streaming Music App";
      categories = [ "Audio" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/{${pname},applications,pixmaps}
    cp -a {locales,resources} $out/share/${pname}
    cp -a $out/share/${pname}/resources/media/icon.png $out/share/pixmaps/nuclear.png

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
  '';

  meta = with lib; {
    description = "Streaming music player that finds free music for you";
    homepage = "https://nuclear.js.org/";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.ivar ];
    platforms = [ "x86_64-linux" ];
  };
}
