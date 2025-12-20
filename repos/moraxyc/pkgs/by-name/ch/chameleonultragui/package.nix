{
  lib,
  flutter335,
  fetchFromGitHub,
  imagemagick,
  autoPatchelfHook,
  zenity,
  ninja,
}:

flutter335.buildFlutterApplication rec {
  pname = "chameleonultragui";
  version = "1.3";

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  src = fetchFromGitHub {
    owner = "GameTec-live";
    repo = "ChameleonUltraGUI";
    tag = "1.3";
    hash = "sha256-9Hwjx1nt/QD520eLMAB5xyFjOGfjZSwS83ARNn8GsFo=";
  };

  gitHashes = {
    file_saver = "sha256-3T4UVDkhjTmLakQqJ0/WCP9NOQlONHAzeK+y5gY7qa8=";
    flutter_libserialport = "sha256-1/EMht8GnctNosmsxpkSxlqEjMfEEL3maf4+vTMwOVw=";
    usb_serial = "sha256-sqGd5ECWVkqsW5ZGlnCV1veHsp0p7inBX2240Xe6NiU=";
  };

  sourceRoot = "${src.name}/chameleonultragui";

  postPatch = ''
    substituteInPlace linux/main.cc \
      --replace-fail '"../shared", "librecovery.so"' '"lib", "librecovery.so"'
  '';

  buildInputs = [
    zenity
    ninja
  ];

  nativeBuildInputs = [
    imagemagick
    autoPatchelfHook
  ];

  postInstall = ''
    install -Dm644 aur/chameleonultragui.desktop $out/share/applications/chameleonultragui.desktop
    for size in 16 22 48 64 128 256 512 1024; do
      local targetdir=$out/share/icons/hicolor/"$size"x"$size"/apps
      mkdir -p $targetdir
      magick aur/chameleonultragui.png -resize "$size"x"$size" \
        $targetdir/chameleonultragui.png
    done
    install -Dm644 build/linux/*/release/shared/librecovery.so $out/app/chameleonultragui/lib
  '';

  meta = {
    description = "GUI for the Chameleon Ultra/Chameleon Lite written in Flutter";
    homepage = "https://github.com/GameTec-live/ChameleonUltraGUI";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
