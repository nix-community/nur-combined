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
  vodozemac-bindings-kazv-unstable,
  cryptopp,
  libcpr,
  catch2_3,
  unstableGitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "libkazv";
  version = "0.7.0-unstable-2024-08-10";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "9f9f367e640c6b62f20105c728bc1a49069ce32c";
    hash = "sha256-suKdLJ0+4CFJ8MuT1sJVd7SDu9hLTel3QlNSZf9+7+g=";
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
    vodozemac-bindings-kazv-unstable
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
