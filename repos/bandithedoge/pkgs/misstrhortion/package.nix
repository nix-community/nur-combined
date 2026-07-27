{
  sources,

  lib,
  stdenv,

  cmake,
  libGL,
  libx11,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.misstrhortion) pname src;
  version = sources.misstrhortion.date;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
  ];

  meta = {
    description = "DPF port of Misstortion";
    homepage = "https://github.com/bandithedoge/misstrhortion";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Misstrhortion";
  };
}
