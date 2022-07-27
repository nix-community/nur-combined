{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation rec {
  inherit (sources.kiwmi) src pname version;

  nativeBuildInputs = with pkgs; [
    git
    meson
    ninja
    pkgconfig
  ];

  buildInputs = with pkgs; [
    libxkbcommon
    lua
    pixman
    udev
    wayland
    wayland-protocols
    wlroots
  ];

  mesonBuildType = "release";
  mesonAutoFeatures = "auto";

  mesonFlags = ["-Dkiwmi-version=${version}"];
}
