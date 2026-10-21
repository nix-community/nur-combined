{
  lib,
  stdenv,
  fetchFromGitHub,

  pkg-config,
  cmake,
  ninja,
  spirv-tools,
  qt6,
  breakpad,
  jemalloc,
  cli11,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libxcb,
  libdrm,
  libgbm,
  pipewire,
  pam,
  sysprof,
  polkit,
  glib,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "noctalia-qs";
  version = current.version;

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-qs";
    rev = current.rev;
    hash = current.hash;
  };

  # Qt 6.12 caches the result of the is_complete<> check of Qt's metatype
  # machinery per translation unit. The automoc generated mocs_compilation.cpp
  # puts the moc files of all headers of a target into a single translation
  # unit, so a pointer-typed Q_PROPERTY gets registered while the pointed-to
  # class is still incomplete, and moc later fails with
  # "static assertion failed: Meta Types must be fully defined".
  #
  # Including the counterpart headers after the class definitions makes all
  # involved classes complete before the first meta type is instantiated.
  postPatch = ''
    for spec in \
      "src/wayland/hyprland/ipc/monitor.hpp:workspace.hpp" \
      "src/wayland/hyprland/ipc/workspace.hpp:monitor.hpp" \
      "src/wayland/hyprland/ipc/hyprland_toplevel.hpp:monitor.hpp workspace.hpp" \
      "src/wayland/hyprland/ipc/qml.hpp:hyprland_toplevel.hpp workspace.hpp" \
      "src/x11/i3/ipc/monitor.hpp:workspace.hpp" \
      "src/x11/i3/ipc/qml.hpp:monitor.hpp workspace.hpp" \
      "src/services/pipewire/peak.hpp:qml.hpp" \
      "src/services/pipewire/spectrum.hpp:qml.hpp"
    do
      file=''${spec%%:*}
      headers=''${spec#*:}

      if [ ! -f "$file" ]; then
        echo "postPatch: $file does not exist" >&2
        exit 1
      fi

      for header in $headers; do
        echo "#include \"$header\"" >> "$file"
      done
    done
  '';

  nativeBuildInputs = [
    cmake
    ninja
    qt6.qtshadertools
    spirv-tools
    wayland-scanner
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6.qtsvg
    cli11
    wayland
    wayland-protocols
    libdrm
    libgbm
    breakpad
    jemalloc
    libxcb
    pam
    pipewire
    sysprof
    polkit
    glib
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DISTRIBUTOR" "Nixpkgs")
    (lib.cmakeBool "DISTRIBUTOR_DEBUGINFO_AVAILABLE" true)
    (lib.cmakeFeature "INSTALL_QML_PREFIX" qt6.qtbase.qtQmlPrefix)
    (lib.cmakeFeature "GIT_REVISION" "tag-v${finalAttrs.version}")
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;
  dontStrip = false;

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "noctalia-qs";
    versionFile = "pkgs/noctalia-qs/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubGit {
      owner = "noctalia-dev";
      repo = "noctalia-qs";
      ref = "master";
    }}";
  };

  meta = {
    homepage = "https://github.com/noctalia-dev/noctalia-qs";
    description = "Flexbile QtQuick based desktop shell toolkit";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "quickshell";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
