{ lib, stdenv, fetchFromGitHub, meson, pkg-config, libdrm, xorg
, wayland, wayland-protocols, libxkbcommon, libcap
, SDL2, mesa, libinput, pixman, xcbutilerrors, xcbutilwm, glslang
, ninja, xwayland, libuuid, xcbutilrenderutil
, pipewire, stb, vulkan-loader, seatd
, fetchurl }:

let
  libdrm' = libdrm.overrideAttrs (oldAttrs: (lib.optionalAttrs (lib.strings.versionAtLeast "2.4.112" oldAttrs.version) rec {
    pname = "libdrm";
    version = "2.4.112";

    src = fetchurl {
      url = "https://dri.freedesktop.org/${pname}/${pname}-${version}.tar.xz";
      sha256 = "sha256-ALB3EL0Js1zY2A6vT0SX/if0vs9Gepgw8fXoMk+EIP8=";
    };
  }));
  wayland' = wayland.overrideAttrs (oldAttrs: rec {
    pname = "wayland";
    version = "1.21.0";

    src = fetchurl {
      url = "https://gitlab.freedesktop.org/wayland/wayland/-/releases/${version}/downloads/${pname}-${version}.tar.xz";
      sha256 = "sha256-bcZNf8FoN6aTpRz9suVo21OL/cn0V9RlYoW7lZTvEaw=";
    };

    patches = [];
  });
in stdenv.mkDerivation rec {
  pname = "gamescope";
  version = "3.11.49";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = version;
    sha256 = "sha256-nBoLc3McHAxb9FckBrjPhEvayIyGY9plVLXMk1nB4V8=";
    fetchSubmodules = true;
  };

  buildInputs = with xorg; [
    libX11 libXdamage libXcomposite libXrender libXext libXxf86vm
    libXtst libdrm' vulkan-loader wayland' wayland-protocols
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
