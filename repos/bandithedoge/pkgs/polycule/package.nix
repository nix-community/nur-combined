{
  sources,

  flutter335,
  lib,

  alsa-lib,
  mpv-unwrapped,
  pkg-config,
}:
flutter335.buildFlutterApplication {
  inherit (sources.polycule) pname version src;

  autoPubspecLock = sources.polycule.extract."pubspec.lock";
  gitHashes = lib.genAttrs [
    "matrix"
    "media_kit"
    "media_kit_libs_android_video"
  ] (name: sources.${name}.src.hash);

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
  ];

  postInstall = ''
    mkdir -p $out/share/{applications,dbus-1/services,metainfo,pixmaps,icons/hicolor/scalable/apps}
    cp linux/*.desktop $out/share/applications
    cp linux/*.service $out/share/dbus-1/services
    cp linux/*.metainfo.xml $out/share/metainfo
    cp assets/logo/logo-circle.svg $out/share/pixmaps/business.braid.polycule.svg
    ln -s $out/share/pixmaps/business.braid.polycule.svg $out/share/icons/hicolor/scalable/apps/business.braid.polycule.svg
  '';

  meta = {
    description = "Geeky and efficient [matrix] client for power users";
    homepage = "https://polycule.im/";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.linux;
    mainProgram = "polycule";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
