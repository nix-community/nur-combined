{
  sources,

  stdenv,
  lib,

  libGL,
  liblo,
  libprojectm,
  libx11,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.dpf-plugins) pname src;
  version = lib.removePrefix "v" sources.dpf-plugins.version;

  buildInputs = [
    libGL
    liblo
    libprojectm
    libx11
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Collection of DPF-based plugins for packaging";
    homepage = "https://github.com/DISTRHO/DPF-Plugins";
    license = with lib.licenses; [
      gpl2
      gpl3
      isc
      lgpl3
      mit
    ];
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
