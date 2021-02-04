{ lib, stdenv, cmake, gtest, sources }:

stdenv.mkDerivation {
  pname = "microjson-unstable";
  version = lib.substring 0 10 sources.microjson.date;

  src = sources.microjson;

  postPatch = ''
    substituteInPlace tests/CMakeLists.txt \
      --replace "find_package(microjson CONFIG REQUIRED)" ""
  '';

  nativeBuildInputs = [ cmake gtest ];

  cmakeFlags = [ "-DMICROJSON_MAKE_TESTS=ON" ];

  doCheck = true;

  meta = with lib; {
    inherit (sources.microjson) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
