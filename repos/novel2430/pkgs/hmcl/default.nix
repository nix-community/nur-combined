{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  makeWrapper,
  copyDesktopItems,
  jre,
  xorg,
  glib,
  libGL,
  glfw,
  openal,
  libglvnd,
  alsa-lib,
  wayland,
  vulkan-loader,
  libpulseaudio,
}:
let
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/HMCL-dev/HMCL/refs/heads/main/HMCL/image/hmcl.png";
    hash = "sha256-1OVq4ujA2ZHboB7zEk7004kYgl9YcoM4qLq154MZMGo=";
  };
  libs = [
    libGL
    glfw
    glib
    openal
    libglvnd
    vulkan-loader
    xorg.libX11
    xorg.libXxf86vm
    xorg.libXext
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXtst
    libpulseaudio
    wayland
    alsa-lib
  ];
  # JavaFX
  javafx-version = "17.0.15";
  javafx-base = fetchurl {
    url = "https://repo1.maven.org/maven2/org/openjfx/javafx-base/${javafx-version}/javafx-base-${javafx-version}-linux.jar";
    hash = "sha256-HNu9wU5Ytu+k6aX+5eBLN/CwIKQb853SFIlxoIpmLS0=";
  };
  javafx-graphics = fetchurl {
    url = "https://repo1.maven.org/maven2/org/openjfx/javafx-graphics/${javafx-version}/javafx-graphics-${javafx-version}-linux.jar";
    hash = "sha256-cq1sUZwBU2aNrUiPZ62EGeRltq9cH2RDMhwr8GSKHg0=";
  };
  javafx-controls = fetchurl {
    url = "https://repo1.maven.org/maven2/org/openjfx/javafx-controls/${javafx-version}/javafx-controls-${javafx-version}-linux.jar";
    hash = "sha256-JDtmqdSy7IIVPpDuJKvIFOtH4HqFLoIwnnnxr6eOw4U=";
  };
in
stdenv.mkDerivation rec {
  pname = "hmcl";
  version = "3.7.3";

  src = fetchurl {
    url = "https://github.com/HMCL-dev/HMCL/releases/download/v${version}/HMCL-${version}.jar";
    hash = "sha256-VE/83KD1xIrkD6BGBK0rJpbKuNPOpmNSC/RHjhRsGco=";
  };

  dontUnpack = true;

  desktopItems = [
    (makeDesktopItem {
      name = "HMCL";
      exec = "hmcl";
      icon = "hmcl";
      comment = meta.description;
      desktopName = "HMCL";
      categories = [ "Game" ];
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/hmcl}
    cp $src $out/lib/hmcl/hmcl.jar
    install -Dm644 ${icon} $out/share/icons/hicolor/32x32/apps/hmcl.png

    mkdir -p $out/lib/hmcl-javafx
    cp ${javafx-base} $out/lib/hmcl-javafx
    cp ${javafx-graphics} $out/lib/hmcl-javafx
    cp ${javafx-controls} $out/lib/hmcl-javafx

    makeWrapper ${jre}/bin/java $out/bin/hmcl \
      --add-flags "--module-path \"$out/lib/hmcl-javafx\"" \
      --add-flags "--add-modules javafx.controls" \
      --add-flags "-jar $out/lib/hmcl/hmcl.jar" \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath libs} \

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://hmcl.huangyuhui.net";
    description = "A Minecraft Launcher which is multi-functional, cross-platform and popular";
    mainProgram = "hmcl";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
