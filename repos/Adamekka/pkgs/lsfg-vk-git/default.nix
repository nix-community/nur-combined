{ cmake
, fetchFromGitHub
, lib
, llvmPackages
, maintainer
, ninja
, qt6
, unstableGitUpdater
, vulkan-headers
,
}:

llvmPackages.stdenv.mkDerivation {
  pname = "lsfg-vk-git";
  version = "0-unstable-2026-08-28";

  src = fetchFromGitHub {
    hash = "sha256-1HfVRaExIhtD+yRgu0y1x02VVIT/lW1xm1oL7bxwoMA=";
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    rev = "0213be9ff93121283ad46a27119f40ece0e6f301";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    vulkan-headers
  ];

  cmakeFlags = [
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_INSTALL_XDG_FILES=ON"
    "-DLSFGVK_LAYER_LIBRARY_PATH=${builtins.placeholder "out"}/lib/liblsfg-vk-layer.so"
  ];

  # The Qt Quick UI does not inherit the system dark theme consistently.
  postPatch = ''
    substituteInPlace lsfg-vk-ui/rsc/UI.qml \
      --replace-fail '    visible: true' '    visible: true

    color: palette.window
    palette.alternateBase: "#242424"
    palette.base: "#1b1b1b"
    palette.brightText: "#ffffff"
    palette.button: "#303030"
    palette.buttonText: "#eeeeee"
    palette.dark: "#181818"
    palette.highlight: "#3584e4"
    palette.highlightedText: "#ffffff"
    palette.light: "#4a4a4a"
    palette.mid: "#343434"
    palette.placeholderText: "#9a9a9a"
    palette.text: "#eeeeee"
    palette.window: "#1e1e1e"
    palette.windowText: "#eeeeee"'
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "develop";
    # Upstream's stable tags are still 1.x; this package follows 2.0 development.
    hardcodeZeroVersion = true;
    url = "https://github.com/PancakeTAS/lsfg-vk.git";
  };

  meta = {
    description = "Vulkan layer for Lossless Scaling frame generation";
    homepage = "https://github.com/PancakeTAS/lsfg-vk";
    license = lib.licenses.gpl3Only;
    mainProgram = "lsfg-vk-ui";
    maintainers = [ maintainer ];
    platforms = lib.platforms.linux;
  };
}
