{ lib, stdenv, fetchFromGitHub, cmake, libcpr, boost, catch2, trompeloeil }:

stdenv.mkDerivation (finalAttrs: {
  pname = "influxdb-cxx";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "offa";
    repo = "influxdb-cxx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ALv6RnWcvonNfoFJfbjVyUdPZ3FWBavGXhvppr5UdWM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libcpr boost ]
    ++ lib.optionals finalAttrs.doCheck [ catch2 trompeloeil ];

  cmakeFlags = [
    "-DINFLUXCXX_TESTING=${if finalAttrs.doCheck then "ON" else "OFF"}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "InfluxDB C++ client library";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
