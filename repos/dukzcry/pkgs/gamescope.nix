{ lib, stdenv, fetchFromGitHub, meson, pkgconfig, libdrm, xorg
, wayland, wayland-protocols, libxkbcommon, libcap
, SDL2, mesa, libinput, pixman, xcbutilerrors, xcbutilwm, glslang
, ninja, makeWrapper, xwayland, libuuid, xcbutilrenderutil
, pipewire, stb, writeText, wlroots, vulkan-loader }:

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
in stdenv.mkDerivation rec {
  pname = "gamescope";
  version = "3.11.32";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = version;
    sha256 = "sha256-5VoNchJNopuwsWzC8InikeuMsjDuo6DdKDqG5WyWl3c=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    substituteInPlace meson.build \
      --replace "force_fallback_for=wlroots,libliftoff" "force_fallback_for=libliftoff"
  '';

  postInstall = ''
    wrapProgram $out/bin/gamescope \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"
  '';

  buildInputs = with xorg; [
    libX11 libXdamage libXcomposite libXrender libXext libXxf86vm
    libXtst libdrm vulkan-loader wayland wayland-protocols
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
  };
}
