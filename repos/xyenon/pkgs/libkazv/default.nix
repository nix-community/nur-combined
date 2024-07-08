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
  version = "0.6.0-unstable-2024-07-06";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "8e34891d0d292427a67cf8cfe3eed7696d204b7f";
    hash = "sha256-Gu3KWwj0XmsPnk1UHfFGZXsQrxc1TFJIwpfbHJIJHfQ=";
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
