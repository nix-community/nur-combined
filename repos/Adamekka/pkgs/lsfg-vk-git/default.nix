{ cmake
, fetchgit
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
  version = "0-unstable-2026-09-08";

  src = fetchgit {
    hash = "sha256-pqPzNmdGAAzTmPc7Shr+PCRDtIIR4/KOu6RgO/W8iHQ=";
    rev = "0e7a3898c1285b13df8596f2bd2cbb8f85b4383b";
    url = "https://git.lsfg-vk.dev/lsfg-vk.git";
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
    "-DLSFGVK_LAYER_LIBRARY_PATH=${builtins.placeholder "out"}/lib/liblsfg-vk-layer.so"
  ];

  # The Qt Quick UI does not inherit the system dark theme consistently.
  postPatch = ''
    substituteInPlace lsfg-vk-ui/resources/UI.qml \
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
    branch = "master";
    # Keep the existing unstable version scheme while following upstream Git.
    hardcodeZeroVersion = true;
    url = "https://git.lsfg-vk.dev/lsfg-vk.git";
  };

  meta = {
    description = "Vulkan layer for Lossless Scaling frame generation";
    homepage = "https://git.lsfg-vk.dev/lsfg-vk";
    license = lib.licenses.gpl3Only;
    mainProgram = "lsfg-vk-ui";
    maintainers = [ maintainer ];
    platforms = lib.platforms.linux;
  };
}
