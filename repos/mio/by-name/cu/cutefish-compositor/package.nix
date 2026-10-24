{
  callPackage,
  cutefish-toolkit,
  cutefish-framework,
  cutefish-core,
  xdg-desktop-portal-cutefish,
  xwayland,
  wayland,
  wayland-protocols,
  wayland-scanner,
  seatd,
  libdrm,
  libgbm,
  mesa,
  libglvnd,
  libxkbcommon,
  libinput,
  systemd,
  pipewire,
  pam,
  fontconfig,
  freetype,
  harfbuzz,
  icu,
  libxcb,
  xorgproto,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-compositor";

  postPatch = ''
    substituteInPlace CMakeLists.txt tests/CMakeLists.txt \
      --replace-fail '${"\${CMAKE_INSTALL_FULL_LIBEXECDIR}"}/xdg-desktop-portal-cutefish' \
        '${xdg-desktop-portal-cutefish}/libexec/xdg-desktop-portal-cutefish' \
      --replace-fail '${"\${CMAKE_INSTALL_FULL_LIBEXECDIR}"}/cutefish-screenrecorder' \
        '${cutefish-core}/libexec/cutefish-screenrecorder'
    substituteInPlace src/core/compositor_shell.cpp \
      --replace-fail '/usr/bin/cutefish-services' '${cutefish-core}/bin/cutefish-services' \
      --replace-fail '/usr/bin/cutefish-polkit-agent' '${cutefish-core}/bin/cutefish-polkit-agent'
    substituteInPlace src/xwayland/xwayland_server.h \
      --replace-fail '/usr/bin/Xwayland' '${xwayland}/bin/Xwayland'
    substituteInPlace src/shell/wallpaper/wallpaper.cpp src/session/secure_container.cpp \
      --replace-fail '/usr/share/backgrounds/cutefishos/default.jpg' \
        '/run/current-system/sw/share/backgrounds/cutefishos/default.jpg'
    substituteInPlace src/auth/login_sessions.cpp \
      --replace-fail '{"/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"}' \
        '{"/run/current-system/sw/share/wayland-sessions", "/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"}'
    substituteInPlace src/cursor/theme.cpp \
      --replace-fail 'paths.push_back("/usr/share/pixmaps");' \
        'for (const auto &data : base::paths::dataDirectories())
            paths.push_back(data + "/pixmaps");
        paths.push_back("/usr/share/pixmaps");'
  '';

  extraNativeBuildInputs = [ wayland-scanner ];

  extraBuildInputs = [
    cutefish-toolkit
    cutefish-framework
    wayland
    wayland-protocols
    seatd
    libdrm
    libgbm
    mesa
    libglvnd
    libxkbcommon
    libinput
    systemd
    pipewire
    pam
    fontconfig
    freetype
    harfbuzz
    icu
    libxcb
    xorgproto
  ];

  meta = {
    description = "Wayland compositor, shell and lock screen for the Cutefish desktop";
    mainProgram = "cutefish-compositor";
  };
}
