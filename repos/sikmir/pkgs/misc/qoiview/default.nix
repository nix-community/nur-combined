{ lib, stdenv, fetchFromGitHub, cmake, xorg, libglvnd }:

stdenv.mkDerivation rec {
  pname = "qoiview";
  version = "2021-12-22";

  src = fetchFromGitHub {
    owner = "floooh";
    repo = "qoiview";
    rev = "ccc7ae1fa1b80716f243115d3855aba7a49aa6b8";
    hash = "sha256-8QIDEBlzUSKPdOhmzbSwhfgy/A2QceWeinIQQe3J7h4=";
  };

  nativeBuildInputs = [ cmake ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isLinux (with xorg; [
    "-I${libX11.dev}/include"
    "-I${xorgproto}/include"
    "-I${libXi.dev}/include"
    "-I${libXext.dev}/include"
    "-I${libXfixes.dev}/include"
    "-I${libXcursor.dev}/include"
    "-I${libglvnd.dev}/include"
  ]);

  NIX_LDFLAGS = lib.optionals stdenv.isLinux (with xorg; [
    "-L${libX11}/lib"
    "-L${libXi}/lib"
    "-L${libXcursor}/lib"
    "-L${libglvnd}/lib"
  ]);

  installPhase = ''
    install -Dm755 qoiview -t $out/bin
  '';

  meta = with lib; {
    description = "QOI image viewer on top of the Sokol headers";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
