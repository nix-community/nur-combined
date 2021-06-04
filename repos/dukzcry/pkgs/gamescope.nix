{ lib, stdenv, fetchFromGitHub, meson, pkgconfig, libX11, libXdamage
, libXcomposite, libXrender, libXext, libXxf86vm, libXtst, libdrm
, vulkan-loader, wayland, wayland-protocols, libxkbcommon, libcap
, SDL2, mesa, libinput, pixman, xcbutilerrors, xcbutilwm, glslang
, ninja, libXi, makeWrapper, xwayland, libXres, libuuid, xcbutilrenderutil }:

stdenv.mkDerivation rec {
  pname = "gamescope";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    rev = version;
    sha256 = "1712wz58wjr7gyglapv5l7ykbx15wjz816xa6fj1gw1hx2ky7c7k";
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

  buildInputs = [
    libX11 libXdamage libXcomposite libXrender libXext libXxf86vm
    libXtst libdrm vulkan-loader wayland wayland-protocols
    libxkbcommon libcap SDL2 mesa libinput pixman xcbutilerrors
    xcbutilwm libXi libXres libuuid xcbutilrenderutil xwayland
  ];
  nativeBuildInputs = [ meson pkgconfig glslang ninja makeWrapper ];

  meta = with lib; {
    description = "The micro-compositor formerly known as steamcompmgr";
    license = licenses.bsd2;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
