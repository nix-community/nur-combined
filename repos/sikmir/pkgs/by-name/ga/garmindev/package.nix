{
  lib,
  stdenv,
  fetchurl,
  cmake,
  libusb-compat-0_1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "garmindev";
  version = "0.3.4";

  src = fetchurl {
    url = "mirror://sourceforge/qlandkartegt/garmindev-${finalAttrs.version}.tar.gz";
    sha256 = "1mc7rxdn9790pgbvz02xzipxp2dp9h4hfq87xgawa18sp9jqzhw6";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libusb-compat-0_1 ];

  env.NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  meta = {
    homepage = "http://www.qlandkarte.org/";
    description = "Garmin Device Drivers for QlandkarteGT";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = true;
  };
})
