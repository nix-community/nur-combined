{ lib
, stdenv
, fetchFromGitHub
, cmake
, uhd
, rtl-sdr
, hackrf
, sox
, fdk_aac
, boost181
, gnuradio-boost181
, git
, spdlog
, gmp
, volk
, openssl
, curl
, mpir
}:

stdenv.mkDerivation rec {
  pname = "trunk-recorder";
  version = "5.1.0";

  # src = ./trunk-recorder;
  src = fetchFromGitHub {
    owner = "robotastic";
    repo = "trunk-recorder";
    rev = "v${version}";
    hash = "sha256-Bta/NP+ApWTZat0IwUd4TXdajWDUZ9Be7TFRs6Q3u90=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = let 
    # # Recent updates upgraded boost to an incompatible version because trunk-recorder uses deprecated functions.
    # # Since boost versions have to match, override it to the last known working version
    # gnuradio' = (gnuradio.override { unwrapped = gnuradio.unwrapped.override { boost = boost181; }; });
  in [
    uhd
    rtl-sdr
    hackrf
    sox
    fdk_aac
    gnuradio-boost181
    gnuradio-boost181.passthru.pkgs.osmosdr
    git
    spdlog
    gmp
    boost181
    volk
    openssl
    curl
    mpir
  ];


  cmakeFlags = [
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  postInstall = ''
    # include/trunk-recorder/git.h points to a missing target: /nix/store....
    find $out -name git.h -delete
  '';

  meta = with lib; {
    description = "Records calls from a Trunked Radio System (P25 & SmartNet)";
    homepage = "https://github.com/robotastic/trunk-recorder";
    changelog = "https://github.com/robotastic/trunk-recorder/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "trunk-recorder";
    platforms = platforms.all;
  };
}
