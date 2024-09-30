{ lib
, stdenv
, fetchFromGitLab
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "pmt";
  version = "1.3.1";

  src = fetchFromGitLab {
    domain = "git.astron.nl";
    owner = "RD";
    repo = "pmt";
    rev = "c6b44f2060b5c4ed143ae28bea8c48b64640b89d";
    sha256 = "sha256-2YsG9YU+Ao9x0LHW9w7ImJoJx0LVGCGyjHbXijV/FFM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DPMT_BUILD_RAPL=ON" ] ++ lib.optional buildShared "-DBUILD_SHARED_LIBS=ON";

  meta = with lib; {
    description = "High-level software library capable of collecting power consumption measurements on various hardware";
    homepage = "https://git.astron.nl/RD/pmt";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

