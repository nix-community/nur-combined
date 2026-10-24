{
  mkCutefishDerivation,
  cutefish-toolkit,
  cutefish-framework,
  icu,
  expat,
  libxkbcommon,
  fontconfig,
  libxcrypt,
  systemd,
  pipewire,
  libX11,
  libXcursor,
  xorgproto,
}:

mkCutefishDerivation {
  pname = "cutefish-settings";

  postPatch = ''
    substituteInPlace cutefish-settings.desktop \
      --replace-fail 'Exec=/usr/bin/cutefish-settings' 'Exec=cutefish-settings'
    substituteInPlace src/pages/keyboard/keyboard.cpp \
      --replace-fail '/usr/share/X11/xkb/rules/evdev.xml' \
        '/run/current-system/sw/share/X11/xkb/rules/evdev.xml'
    substituteInPlace src/pages/datetime/timezonemap.cpp \
      --replace-fail '/usr/share/zoneinfo/zone.tab' '/etc/zoneinfo/zone.tab'
    substituteInPlace src/pages/accounts/passwordchanger.h \
      --replace-fail 'std::string program = "/usr/bin/passwd"' \
        'std::string program = "/run/wrappers/bin/passwd"'
    substituteInPlace src/pages/accounts/passwordchanger.cpp \
      --replace-fail 'PATH=/usr/sbin:/usr/bin:/sbin:/bin' \
        'PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  '';

  extraBuildInputs = [
    cutefish-toolkit
    cutefish-framework
    icu
    expat
    libxkbcommon
    fontconfig
    libxcrypt
    systemd
    pipewire
    libX11
    libXcursor
    xorgproto
  ];

  meta = {
    description = "System Settings for the Cutefish desktop";
    mainProgram = "cutefish-settings";
  };
}
