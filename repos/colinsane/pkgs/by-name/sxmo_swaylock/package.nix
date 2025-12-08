# STATUS:
# - it unlocks via physical keyboard
# - pressing the OSK results in... nothing (on my laptop)
#   maybe it's listening only on a single input device?
#   maybe it's incompatible with pam mode, somehow?
{
  cairo,
  fetchFromGitHub,
  gdk-pixbuf,
  lib,
  libxcrypt,
  libxkbcommon,
  meson,
  ninja,
  pam,
  pkg-config,
  scdoc,
  stdenv,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation rec {
  pname = "sxmo_swaylock";
  version = "1.6.11-unstable-2023-04-26";  #< from meson.build

  src = fetchFromGitHub {
    owner = "KaffeinatedKat";
    repo = "sxmo_swaylock";
    rev = "63619c857d9fb5f8976f0380c6670123a4028211";  # 2023-04-26
    hash = "sha256-vs0VHO1QBstwLXyLJ/6SSypQmh2DyFJZd40+73JsIaQ=";
    # rev = "e33d885beddd34ea6ce5e854df6ab2ae554adcf2";  # 2023-04-04
    # hash = "sha256-ouCzHAuZWNF7o/tpcvWzaBsH/7WRrQwUaOKuxDbCsr4=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "sources += ['pam.c']" "sources += ['src/pam.c']"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    libxcrypt
    libxkbcommon
    pam
    wayland
    wayland-protocols
  ];

  # env.NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion -Wno-error=implicit-function-declaration";
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  meta = with lib; {
    description = "sxmo lockscreen with swaylock";
    longDescription = ''
      sxmo_swaylock is a fork of swaylock-effects with the touchscreen keypad
      from swaylock-mobile. This is intended to be used with sxmo on mobile
      devices, as sxmo currently does not have a proper password protected lockscreen
    '';
    inherit (src.meta) homepage;
    mainProgram = "swaylock";
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
}
