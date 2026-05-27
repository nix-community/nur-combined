{
  lib,
  stdenv,
  runCommand,
  fetchFromGitHub,
  cmake,
  makeWrapper,
  patchutils,
  pkg-config,
  nix-update-script,
  hyprland,
  hyprland-protocols,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  libdrm,
  libgbm,
  libuuid,
  pipewire,
  qt6,
  qtbase ? qt6.qtbase,
  qttools ? qt6.qttools,
  qtwayland ? qt6.qtwayland,
  wrapQtAppsHook ? qt6.wrapQtAppsHook,
  sdbus-cpp_2,
  slurp,
  wayland,
  wayland-protocols,
  wayland-scanner,
  debug ? false,
}:
let
  pr268Patch =
    runCommand "xdg-desktop-portal-hyprland-pr-268.patch"
      {
        nativeBuildInputs = [ patchutils ];
      }
      ''
        filterdiff -x '*/subprojects/hyprland-protocols' ${./268.diff} > "$out"
      '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-hyprland";
  version = "1.3.12";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "xdg-desktop-portal-hyprland";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B7nwX0PE0KBo1/ZtuwJtA7dBG6gdPW5tSBb0skY8DHA=";
  };

  # patched with Input Capture Desktop Portal
  # https://github.com/hyprwm/xdg-desktop-portal-hyprland/pull/268
  patches = [
    pr268Patch
  ];

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    wrapQtAppsHook
    hyprwayland-scanner
  ];

  buildInputs = [
    hyprland-protocols
    hyprlang
    hyprutils
    libdrm
    libgbm
    libuuid
    pipewire
    qtbase
    qttools
    qtwayland
    sdbus-cpp_2
    wayland
    wayland-protocols
    wayland-scanner
  ];

  cmakeBuildType = if debug then "Debug" else "RelWithDebInfo";

  dontStrip = debug;

  dontWrapQtApps = true;

  postInstall = ''
    wrapProgramShell $out/bin/hyprland-share-picker \
      "''${qtWrapperArgs[@]}" \
      --prefix PATH ":" ${
        lib.makeBinPath [
          slurp
          hyprland
        ]
      }

    wrapProgramShell $out/libexec/xdg-desktop-portal-hyprland \
      --prefix PATH ":" ${lib.makeBinPath [ (placeholder "out") ]}
  '';

  passthru.updateScript = [
    "wget https://patch-diff.githubusercontent.com/raw/hyprwm/xdg-desktop-portal-hyprland/pull/268.diff -O ./packages/xdg-desktop-portal-hyprland/268.diff"
    "&&"
  ]
  ++ nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "xdg-desktop-portal backend for Hyprland; patched with Input Capture support";
    homepage = "https://github.com/hyprwm/xdg-desktop-portal-hyprland";
    changelog = "https://github.com/hyprwm/xdg-desktop-portal-hyprland/releases/tag/v${finalAttrs.version}";
    mainProgram = "hyprland-share-picker";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
