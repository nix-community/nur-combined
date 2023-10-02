{ stdenv, lib, fetchurl, appimageTools, makeWrapper, electron_26 }:

let electron = electron_26;
in stdenv.mkDerivation rec {
  pname = "chengla-electron";
  version = "1.0.6";

  src = fetchurl {
    url =
      "https://github.com/pokon548/chengla-for-linux/releases/download/v${version}/chengla-${version}.AppImage";
    sha256 = "sha256-bs+HlXNBRQn2egEHQgT1EIVTuGn+D1akGrtf1L96EUI=";
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

    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/icons/hicolor/0x0

    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/chengla-linux-unofficial.desktop $out/share/applications/chengla-linux-unofficial.desktop
    cp -a ${appimageContents}/usr/share/icons/hicolor/0x0/apps $out/share/icons/hicolor/0x0

    substituteInPlace $out/share/applications/chengla-linux-unofficial.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    description = "Chengla unofficial client for Linux";
    homepage = "https://github.com/pokon548/chengla-for-linux";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
