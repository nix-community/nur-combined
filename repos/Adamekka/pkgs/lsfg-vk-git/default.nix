{ cmake
, fetchFromGitHub
, lib
, llvmPackages
, ninja
, qt6
, unstableGitUpdater
, vulkan-headers
,
}:

llvmPackages.stdenv.mkDerivation {
  pname = "lsfg-vk-git";
  version = "0-unstable-2026-06-27";

  src = fetchFromGitHub {
    hash = "sha256-meXXl1hHvmOaVjeGglsYSmVJiaxuijfPesjs8wuKrfs=";
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    rev = "e282e243ad79f438c82ba4310eff7a1ea1732db3";
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
    platforms = lib.platforms.linux;
  };
}
