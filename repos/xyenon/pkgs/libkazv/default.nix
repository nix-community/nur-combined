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
  version = "0.5.0-unstable-2024-07-04";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "9f2534700a43a71f1ca1b048be45f93feecf7794";
    hash = "sha256-UK0scDIkL96m0ouCuneImX3IumaIJPTOTkNSCqW6lOE=";
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
