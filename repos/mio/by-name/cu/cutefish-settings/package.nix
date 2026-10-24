{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
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

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-settings";
  version = cu.version "2026-10-21";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "settings";
    rev = "724827e0fd2a56dac5d506075b5a891e516b4015";
    hash = "sha256-5gUYjqVd9WpAYE2QYWUO983ekQT03uRk8BjQPVsKqTc=";
  };

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

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
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

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "System Settings for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-settings";
  };
}
