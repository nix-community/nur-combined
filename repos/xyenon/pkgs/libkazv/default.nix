{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  lager-unstable,
  immer-unstable,
  zug-unstable,
  boost,
  nlohmann_json,
  olm,
  cryptopp,
  libcpr,
  catch2_3,
  unstableGitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "libkazv";
  version = "0.6.0-unstable-2024-07-13";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "d942e189d3095d5032868b95d90b10d8b1049ec4";
    hash = "sha256-IM+fBsgmVZLNEkmwh1js0qBt2VPG18XmN14CMUqN2wo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  propagatedBuildInputs = [
    lager-unstable
    immer-unstable
    zug-unstable
    boost
    nlohmann_json
    olm
    cryptopp

    libcpr

    catch2_3
  ];

  cmakeFlags = [
    "-Dlibkazv_BUILD_KAZVJOB=ON"
    "-Dlibkazv_INSTALL_HEADERS=ON"
    "-Dlibkazv_BUILD_EXAMPLES=OFF"
    "-Dlibkazv_BUILD_TESTS=ON"
  ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A sans-io C++ (gnu++17) matrix client library";
    homepage = "https://lily-is.land/kazv/libkazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
