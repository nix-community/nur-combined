# TODO: figure out plugin scanning with carla
{
  sources,

  lib,
  stdenv,

  libGL,
  libx11,
  libxcursor,
  libxext,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.ildaeil) pname src;
  version = sources.ildaeil.date;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxcursor
    libxext
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "mini-plugin host as plugin";
    homepage = "https://github.com/DISTRHO/Ildaeil";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "Ildaeil";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
