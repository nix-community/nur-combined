{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cairo,
  gnome2,
  gtk3,
  libbsd,
  libevdev,
  libinput,
  libwnck3,
  libxkbcommon,
  pixman,
  wayland,
  wayland-protocols,
  wlroots,
  xfce,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "xfwm4-wayland";
  version = "unstable-2022-12-24";

  src = fetchFromGitHub {
    owner = "adlocode";
    repo = "xfwm4";
    rev = "4b9cb8eefd3e10b0f16e973d804f0531b1e34219";
    hash = "sha256-4nLagxEKvB8tocyW4CYkGO/SJ03AvDSGeYTtFsRJbPg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cairo
    gnome2.pango
    gtk3
    libbsd
    libevdev
    libinput
    libwnck3
    libxkbcommon
    pixman
    wayland
    wayland-protocols
    wlroots
    xfce.libxfce4util
    xfce.libxfce4ui
    xfce.xfconf
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrandr
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/adlocode/xfwm4/archive/refs/heads/wayland.zip";
    changelog = "https://github.com/adlocode/xfwm4/blob/${src.rev}/NEWS";
    license = licenses.gpl2Only;
  };
}
