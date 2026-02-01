{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  npupnp,
  curl,
  expat,
}:

stdenv.mkDerivation rec {
  pname = "libupnpp";
  version = "1.0.3";

  src = fetchurl {
    url = "http://www.lesbonscomptes.com/upmpdcli/downloads/${pname}-${version}.tar.gz";
    sha256 = "07IBYZqEg3J53Ebut8yqp5YNQ3LbEbQ88rFDtdm9Mi4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    npupnp
    curl
    expat
  ];

  dontWrapQtApps = true;

  enableParallelBuilding = true;

  configurePhase = ''
    meson setup builddir . \
      --prefix=$out
  '';

  buildPhase = ''
    ninja -C builddir -j ${stdenv.hostPlatform.parsed.cpu.cores or "$NIX_BUILD_CORES"}
  '';

  installPhase = ''
    ninja -C builddir install
  '';

  meta = with lib; {
    description = "C++ wrapper for npupnp (for upmpdcli and upplay)";
    homepage = "https://www.lesbonscomptes.com/upmpdcli/";
    license = licenses.lgpl21Plus;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
  };
}
