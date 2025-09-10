{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  cairo,
  fribidi,
  libdatrie,
  libGL,
  libjpeg,
  libselinux,
  libsepol,
  libthai,
  libxkbcommon,
  pango,
  pcre,
  pcre2,
  utillinux,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libXdmcp,
  debug ? false,
}:
stdenv.mkDerivation (finalAttre: {
  pname = "hyprmag" + lib.optionalString debug "-debug";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "SIMULATAN";
    repo = "hyprmag";
    tag = "${finalAttre.version}";
    hash = "sha256-wEis7Z21RS+yuJGI8aSBVLkTvUWZQ6sej+Wx1movLAM=";
  };

  cmakeBuildType = if debug then "Debug" else "Release";
  cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}" ];
  buildTargets = [ "hyprmag" ];
  installTargets = [ "install" ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    fribidi
    libdatrie
    libGL
    libjpeg
    libselinux
    libsepol
    libthai
    pango
    pcre
    pcre2
    wayland
    wayland-protocols
    wayland-scanner
    libXdmcp
    libxkbcommon
    utillinux
  ];

  outputs = [
    "out"
    "man"
  ];

  meta = {
    homepage = "https://github.com/SIMULATAN/hyprmag";
    description = "A wlroots-compatible Wayland screen magnifier with basic customization options.";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "hyprmag";
  };
})
