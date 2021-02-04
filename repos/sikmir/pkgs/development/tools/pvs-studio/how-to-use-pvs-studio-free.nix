{ lib, stdenv, cmake, sources }:

stdenv.mkDerivation {
  pname = "how-to-use-pvs-studio-free-unstable";
  version = lib.substring 0 10 sources.how-to-use-pvs-studio-free.date;

  src = sources.how-to-use-pvs-studio-free;

  nativeBuildInputs = [ cmake ];

  postPatch = lib.optionalString (!stdenv.isDarwin) ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX \"/usr\")" ""
  '' + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace CMakeLists.txt \
      --replace "stdc++fs" "c++fs"
  '';

  meta = with lib; {
    inherit (sources.how-to-use-pvs-studio-free) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
