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
  version = "unstable-2024-02-21";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    rev = "205679d25350ed657bdb517e958d80bc03877bc4";
    hash = "sha256-Q4BjbUPIs4MsZbkEJHQOjXHdG99uekUDDKk68KiTg/o=";
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
