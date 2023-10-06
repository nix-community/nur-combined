{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, libacars, libsndfile, paho-mqtt-c, rtl-sdr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "acarsdec";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "TLeconte";
    repo = "acarsdec";
    rev = "acarsdec-${finalAttrs.version}";
    hash = "sha256-MBy9Xq5ufusqSKGe40JxgnFeo4wnabThbDpGEE6u1so=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libacars libsndfile paho-mqtt-c rtl-sdr ];

  cmakeFlags = [
    (lib.cmakeBool "rtl" true)
    (lib.cmakeBool "airspy" false)
    (lib.cmakeBool "sdrplay" false)
  ];

  meta = with lib; {
    description = "ACARS SDR decoder";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
