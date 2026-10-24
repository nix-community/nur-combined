{
  mkCutefishDerivation,
  cutefish-toolkit,
  systemd,
  pipewire,
  wayland,
  wayland-protocols,
  wayland-scanner,
  mesa,
  libgbm,
  libdrm,
}:

mkCutefishDerivation {
  pname = "xdg-desktop-portal-cutefish";

  extraNativeBuildInputs = [ wayland-scanner ];

  extraBuildInputs = [
    cutefish-toolkit
    systemd
    pipewire
    wayland
    wayland-scanner
    wayland-protocols
    mesa
    libgbm
    libdrm
  ];

  meta = {
    description = "XDG desktop portal backend for the Cutefish desktop";
  };
}
