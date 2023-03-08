{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.dpf-plugins) pname src version;

  buildInputs = with pkgs; [
    libGL
    liblo
    projectm
    xorg.libX11
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  enableParallelBuilding = true;

  makeFlags = ["PREFIX=$(out)"];

  meta = with pkgs.lib; {
    description = "Collection of DPF-based plugins for packaging";
    homepage = "https://github.com/DISTRHO/DPF-Plugins";
    license = with licenses; [
      gpl2
      gpl3
      isc
      lgpl3
      mit
    ];
    platforms = platforms.linux;
  };
}
