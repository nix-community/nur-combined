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
  version = "unstable-2024-03-14";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "c7217ec794e1c6b200c149c4d8f7a0fc1ba66cf7";
    hash = "sha256-YMd2mxG8wnvlyX497LhH60quLSL66/DvpnckQFMw5WM=";
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
