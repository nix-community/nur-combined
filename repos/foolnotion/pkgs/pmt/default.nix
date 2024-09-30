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
    rev = "${version}";
    hash = "sha256-SIV1pSHgRANYt80kMHxYY4vvH6uQl6sMwxMo0EznX6E=";
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

