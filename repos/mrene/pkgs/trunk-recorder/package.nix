{ lib
, stdenv
, fetchFromGitHub
, cmake
, uhd
, rtl-sdr
, hackrf
, sox
, fdk_aac
, boost
, gnuradio
, gnuradioPackages
, git
, spdlog
, gmp
, volk
, openssl
, curl
}:

stdenv.mkDerivation rec {
  pname = "trunk-recorder";
  version = "5.0.0";

  # src = ./trunk-recorder;
  src = fetchFromGitHub {
    owner = "robotastic";
    repo = "trunk-recorder";
    rev = "v${version}";
    hash = "sha256-KcLHE+3NLhEKMJ8y74l384lhoOMG9oy7F+iXpV+y5+Y=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    uhd
    rtl-sdr
    hackrf
    sox
    fdk_aac
    gnuradio
    gnuradioPackages.osmosdr
    git
    spdlog
    gmp
    boost
    volk
    openssl
    curl
  ];


  cmakeFlags = [
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  meta = with lib; {
    description = "Records calls from a Trunked Radio System (P25 & SmartNet";
    homepage = "https://github.com/robotastic/trunk-recorder";
    changelog = "https://github.com/robotastic/trunk-recorder/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "trunk-recorder";
    platforms = platforms.all;
  };
}
