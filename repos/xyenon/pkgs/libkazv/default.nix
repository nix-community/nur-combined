{ lib
, stdenv
, fetchFromGitLab
, cmake
, pkg-config
, lager-unstable
, immer-unstable
, zug-unstable
, boost
, nlohmann_json
, olm
, cryptopp
, libcpr
, catch2_3
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "libkazv";
  version = "unstable-2024-03-17";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "7171e11687eb1f724f87e56d2770d55d0c1c3c52";
    hash = "sha256-hqiautveyfNKYbeVY667sMmxdDV/rqGcTgD8zbwoWR8=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

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

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "A sans-io C++ (gnu++17) matrix client library";
    homepage = "https://lily-is.land/kazv/libkazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
