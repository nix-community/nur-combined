{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libGL,
  liblo,
  libprojectm,
  libx11,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dpf-plugins";
  version = "1.7";
  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "DPF-Plugins";
    rev = "v${finalAttrs.version}";
    hash = "sha256-768DlGZrD2vNoHAuVh3SxQHCIT4l44qORGWajo4bTiA=";
  };

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

  passthru.updateScript = nix-update-script { };

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
})
