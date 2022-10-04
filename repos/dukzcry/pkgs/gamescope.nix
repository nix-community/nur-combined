{ lib, stdenv, fetchFromGitHub, meson, pkg-config, libdrm, xorg
, wayland, wayland-protocols, libxkbcommon, libcap
, SDL2, mesa, libinput, pixman, xcbutilerrors, xcbutilwm, glslang
, ninja, xwayland, libuuid, xcbutilrenderutil
, pipewire, stb, vulkan-loader, seatd }:

stdenv.mkDerivation rec {
  pname = "gamescope";
  version = "3.11.32";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = version;
    sha256 = "sha256-5VoNchJNopuwsWzC8InikeuMsjDuo6DdKDqG5WyWl3c=";
    fetchSubmodules = true;
  };

  buildInputs = with xorg; [
    libX11 libXdamage libXcomposite libXrender libXext libXxf86vm
    libXtst libdrm vulkan-loader wayland wayland-protocols
    libxkbcommon libcap SDL2 mesa libinput pixman xcbutilerrors
    xcbutilwm libXi libXres libuuid xcbutilrenderutil xwayland
    pipewire seatd
  ];
  nativeBuildInputs = [ meson pkg-config glslang ninja ];

  prePatch = ''
    cp -vr "${stb.src}" subprojects/stb
    chmod -R +w subprojects/stb
    cp "subprojects/packagefiles/stb/meson.build" "subprojects/stb/"
  '';

  meta = with lib; {
    description = "The micro-compositor formerly known as steamcompmgr";
    license = licenses.bsd2;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
