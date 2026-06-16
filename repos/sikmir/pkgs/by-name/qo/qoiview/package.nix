{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libglvnd,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qoiview";
  version = "0-unstable-2025-12-02";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "floooh";
    repo = "qoiview";
    rev = "2b7194959f0b17e7d5f10e796ebd11dc08a25285";
    hash = "sha256-4seyxaeBjljdeecKCtOE1cUj0a2zeRG444LwgTsXsvA=";
  };

  nativeBuildInputs = [ cmake ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isLinux (toString [
    "-I${libx11.dev}/include"
    "-I${xorgproto}/include"
    "-I${libxi.dev}/include"
    "-I${libxext.dev}/include"
    "-I${libxfixes.dev}/include"
    "-I${libxcursor.dev}/include"
    "-I${libglvnd.dev}/include"
  ]);

  env.NIX_LDFLAGS = lib.optionalString stdenv.isLinux (toString [
    "-L${libx11}/lib"
    "-L${libxi}/lib"
    "-L${libxcursor}/lib"
    "-L${libglvnd}/lib"
  ]);

  installPhase = ''
    install -Dm755 qoiview -t $out/bin
  '';

  meta = {
    description = "QOI image viewer on top of the Sokol headers";
    homepage = "https://github.com/floooh/qoiview";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
