{ lib, stdenv, fetchFromGitHub, meson, pkgconfig, libdrm, xorg
, wayland, wayland-protocols, libxkbcommon, libcap
, SDL2, mesa, libinput, pixman, xcbutilerrors, xcbutilwm, glslang
, ninja, makeWrapper, xwayland, libuuid, xcbutilrenderutil
, pipewire, stb, writeText, wlroots, vulkan-loader, vulkan-headers }:

let
  stbpc = writeText "stbpc" ''
    prefix=${stb}
    includedir=''${prefix}/include/stb
    Cflags: -I''${includedir}
    Name: stb
    Version: ${stb.version}
    Description: stb
  '';
  stb_ = stb.overrideAttrs (oldAttrs: rec {
    installPhase = ''
      ${oldAttrs.installPhase}
      install -Dm644 ${stbpc} $out/lib/pkgconfig/stb.pc
    '';
  });
  vulkan-headers_ = vulkan-headers.overrideAttrs (oldAttrs: rec {
    version = "1.2.189.1";

    src = fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "Vulkan-Headers";
      rev = "sdk-${version}";
      sha256 = "1qggc7dv9jr83xr9w2h375wl3pz3rfgrk9hnrjmylkg9gz4p9q03";
    };
  });
  vulkan-loader_ = (vulkan-loader.overrideAttrs (oldAttrs: rec {
    version = "1.2.189.1";

    src = fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "Vulkan-Loader";
      rev = "sdk-${version}";
      sha256 = "1745fdzi0n5qj2s41q6z1y52cq8pwswvh1a32d3n7kl6bhksagp6";
    };
  })).override { vulkan-headers = vulkan-headers_; };
in stdenv.mkDerivation rec {
  pname = "gamescope";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = version;
    sha256 = "05a1sj1fl9wpb9jys515m96958cxmgim8i7zc5mn44rjijkfbfcb";
    fetchSubmodules = true;
  };

  preConfigure = ''
    substituteInPlace meson.build \
      --replace "'examples=false'" "'examples=false', 'logind-provider=systemd', 'libseat=disabled'"
  '';

  postInstall = ''
    wrapProgram $out/bin/gamescope \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"
  '';

  buildInputs = with xorg; [
    libX11 libXdamage libXcomposite libXrender libXext libXxf86vm
    libXtst libdrm vulkan-loader_ wayland wayland-protocols
    libxkbcommon libcap SDL2 mesa libinput pixman xcbutilerrors
    xcbutilwm libXi libXres libuuid xcbutilrenderutil xwayland
    pipewire wlroots
  ];
  nativeBuildInputs = [ meson pkgconfig glslang ninja makeWrapper stb_ ];

  meta = with lib; {
    description = "The micro-compositor formerly known as steamcompmgr";
    license = licenses.bsd2;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    broken = true;
  };
}
