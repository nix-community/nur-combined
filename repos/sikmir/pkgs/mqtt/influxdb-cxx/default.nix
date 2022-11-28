{ lib, stdenv, fetchFromGitHub, cmake, curl, boost, catch2, trompeloeil }:

stdenv.mkDerivation (finalAttrs: {
  pname = "influxdb-cxx";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "offa";
    repo = "influxdb-cxx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9CfjW+NEVGCfV+A0PDy9N6attE2eNdgKBXTzZ3g51FM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ curl boost catch2 trompeloeil ];

  meta = with lib; {
    description = "InfluxDB C++ client library";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
