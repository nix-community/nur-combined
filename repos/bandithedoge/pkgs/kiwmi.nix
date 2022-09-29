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
    pkg-config
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

  meta = with pkgs.lib; {
    description = "A fully programmable Wayland Compositor";
    homepage = "https://github.com/buffet/kiwmi";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}
