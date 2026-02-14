{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeDesktopItem,

  autoreconfHook,
  pkg-config,
  gcc13,
  copyDesktopItems,

  alsa-lib,
  libpulseaudio,
  gtk2,
}:
stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "dectalk";
  version = "0-unstable-2023-10-30";

  src = fetchFromGitHub {
    owner = "dectalk";
    repo = "dectalk";
    rev = lib.removePrefix "0-unstable-" finalAttrs.version;
    hash = "sha256-lpXiub6kE49t9kWG0tBqjG4uqWtG/m1/K9L2VjOA2Vk=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  patches = [
    ./fix-bin.patch
    ./fix-fhs.patch
  ];

  patchFlags = [ "-p1" "-d" ".." ];

  postPatch = ''
    sed -i configure.ac -e '/m4_esyscmd_s/c\\t${finalAttrs.version},'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gcc13 # https://github.com/dectalk/dectalk/issues/58
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    libpulseaudio
    gtk2
  ];

  buildPhase = ''
    make -j release
  '';

  installPhase = ''
    runHook preInstall

    make -j install

    mkdir -p $out/share/pixmaps
    install -m 0644 $out/share/bitmaps/dtk.xpm $out/share/pixmaps/dtk.xpm
    install -m 0644 $out/share/bitmaps/pau16a.xpm $out/share/pixmaps/pau16a.xpm

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gspeak";
      desktopName = "GSpeak";
      exec = "gspeak";
      terminal = false;
      icon = "pau16a";
      comment = "Speaking Text Editor";
      categories = [ "Utility" ];
    })
    (makeDesktopItem {
      name = "windic";
      desktopName = "Windic";
      exec = "windic";
      terminal = false;
      icon = "dtk";
      comment = "Windowed Dictionary Complier";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    changelog = "https://github.com/dectalk/dectalk/releases/tag/${lib.removePrefix "0-unstable-" finalAttrs.version}";
    description = "Modern builds for the 90s/00s DECtalk text-to-speech application";
    homepage = "https://github.com/dectalk/dectalk";
    license = lib.licenses.unfree;
    mainProgram = "gspeak";
    platforms = [ "x86_64-linux" ];
  };
})
