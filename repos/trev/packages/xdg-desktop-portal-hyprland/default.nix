{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  makeWrapper,
  pkg-config,
  nix-update-script,
  aquamarine,
  cairo,
  hyprgraphics,
  hyprland-protocols,
  hyprlang,
  hyprtoolkit,
  hyprutils,
  hyprwayland-scanner,
  libdrm,
  libei,
  libgbm,
  libuuid,
  libxdmcp,
  libxkbcommon,
  pipewire,
  pixman,
  sdbus-cpp_2,
  slurp,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  debug ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-hyprland";
  version = "1.4.1-unstable-2026-10-12";

  # RemoteDesktop support on top of upstream: #428, its keyboard fixes, screen
  # casts in remote desktop sessions, and the portal's own input methods from #402
  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "xdg-desktop-portal-hyprland";
    rev = "7af02c6f8943382bcef3f2610dfdf14de901bd91";
    hash = "sha256-Z6qIl+ZVgEgUzZ1lv0Ck0/dzUjNTsNiA9ukl5LF8bP0=";
  };

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    hyprwayland-scanner
  ];

  buildInputs = [
    aquamarine
    # hyprgraphics' headers include it, for the picker
    cairo
    hyprgraphics
    hyprland-protocols
    hyprlang
    hyprtoolkit
    hyprutils
    libdrm
    libei
    libgbm
    libuuid
    libxdmcp
    libxkbcommon
    pipewire
    # and hyprutils' this
    pixman
    sdbus-cpp_2
    systemd
    wayland
    wayland-protocols
    wayland-scanner
  ];

  cmakeBuildType = if debug then "Debug" else "RelWithDebInfo";

  dontStrip = debug;

  postInstall = ''
    wrapProgramShell $out/bin/hyprland-share-picker \
      --prefix PATH ":" ${lib.makeBinPath [ slurp ]}

    wrapProgramShell $out/libexec/xdg-desktop-portal-hyprland \
      --prefix PATH ":" ${lib.makeBinPath [ (placeholder "out") ]}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=feature/remote-desktop"
      # the fork's tags are upstream's, prefixed with v
      "--version-regex=v(.*)"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "xdg-desktop-portal backend for Hyprland, with RemoteDesktop support";
    homepage = "https://github.com/spotdemo4/xdg-desktop-portal-hyprland";
    changelog = "https://github.com/spotdemo4/xdg-desktop-portal-hyprland/commits/feature/remote-desktop";
    mainProgram = "hyprland-share-picker";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
