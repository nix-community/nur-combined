{
  callPackage,
  cutefish-toolkit,
  cutefish-framework,
  systemd,
  icu,
  fontconfig,
  wayland,
  wayland-protocols,
  wayland-scanner,
  mesa,
  libgbm,
  libglvnd,
  libdrm,
  ffmpeg,
  libva,
  pipewire,
  polkit,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-core";

  postPatch = ''
    substituteInPlace session/cutefish-wayland-session \
      --replace-fail 'exec /usr/bin/cutefish-session "$@"' \
        'exec "$(dirname "$(readlink -f "$0")")/cutefish-session" "$@"'
    substituteInPlace session/cutefish-wayland.desktop \
      --replace-fail 'Exec=/usr/bin/cutefish-wayland-session' "Exec=$out/bin/cutefish-wayland-session" \
      --replace-fail 'TryExec=/usr/bin/cutefish-compositor' "TryExec=$out/bin/cutefish-wayland-session"
    substituteInPlace session/processmanager.cpp \
      --replace-fail 'static constexpr char kCompositor[] = "/usr/bin/cutefish-compositor";' \
        '/* cutefish-compositor is resolved from PATH. */' \
      --replace-fail 'm_compositorProcess->start(kCompositor,' \
        'm_compositorProcess->start(base::paths::findExecutable("cutefish-compositor"),'
    substituteInPlace session/CMakeLists.txt \
      --replace-fail 'DESTINATION /usr/lib/systemd/user/xdg-document-portal.service.d' \
        'DESTINATION lib/systemd/user/xdg-document-portal.service.d'
    substituteInPlace session/application.cpp \
      --replace-fail 'setenv("XDG_DATA_DIRS", "/usr/local/share/:/usr/share/", 1);' \
        'setenv("XDG_DATA_DIRS", "/run/current-system/sw/share:/usr/local/share/:/usr/share/", 1);'
    substituteInPlace polkit-agent/authsession.cpp \
      --replace-fail '/usr/lib/polkit-1/polkit-agent-helper-1' \
        '${polkit.out}/lib/polkit-1/polkit-agent-helper-1'
    substituteInPlace cutefish-services/appearance/wallpapermanager.cpp \
      --replace-fail '/usr/share/backgrounds/cutefishos/default.jpg' \
        '/run/current-system/sw/share/backgrounds/cutefishos/default.jpg'
    substituteInPlace cutefish-services/schedule/scheduleutils.cpp \
      --replace-fail '{"/usr/share/zoneinfo/zone1970.tab", "/usr/share/zoneinfo/zone.tab"}' \
        '{"/etc/zoneinfo/zone1970.tab", "/etc/zoneinfo/zone.tab", "/usr/share/zoneinfo/zone1970.tab", "/usr/share/zoneinfo/zone.tab"}'
  '';

  extraNativeBuildInputs = [ wayland-scanner ];

  extraBuildInputs = [
    cutefish-toolkit
    cutefish-framework
    systemd
    icu
    fontconfig
    wayland
    wayland-protocols
    mesa
    libgbm
    libglvnd
    libdrm
    ffmpeg
    libva
    pipewire
  ];

  passthru.providedSessions = [ "cutefish-wayland" ];

  meta = {
    description = "Session, system services, polkit agent and screen recorder for the Cutefish desktop";
    mainProgram = "cutefish-wayland-session";
  };
}
