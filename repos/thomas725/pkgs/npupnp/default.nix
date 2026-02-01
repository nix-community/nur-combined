{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  expat,
  libmicrohttpd,
  curl,
}:

stdenv.mkDerivation rec {
  pname = "npupnp";
  version = "6.2.3";

  src = fetchurl {
    url = "http://www.lesbonscomptes.com/upmpdcli/downloads/libnpupnp-${version}.tar.gz";
    sha256 = "Vj0qnkr+YDcXND3EZnwLicagFwCKxrUiYtoXoeT2u5Y=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    expat
    libmicrohttpd
    curl
  ];

  # Let Nix know this package supports parallel builds
  enableParallelBuilding = true;

  configurePhase = ''
    meson setup builddir . \
      --prefix=$out
  '';

  buildPhase = ''
    # use all allowed cores (Nix sets $NIX_BUILD_CORES / $NIX_BUILD_CORES_MAX)
    ninja -C builddir -j ${stdenv.hostPlatform.parsed.cpu.cores or "$NIX_BUILD_CORES"}
  '';

  installPhase = ''
    ninja -C builddir install
  '';

  meta = with lib; {
    description = "New Portable UPnP library (npupnp) used by libupnpp 1.x and upmpdcli";
    homepage = "https://www.lesbonscomptes.com/upmpdcli/";
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
  };
}
