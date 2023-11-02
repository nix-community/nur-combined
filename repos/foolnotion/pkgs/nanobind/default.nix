{ lib, stdenv, fetchFromGitHub, cmake, robin-map, python,
buildShared ? false,
enableTesting ? false
}:

stdenv.mkDerivation rec {
  pname = "nanobind";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "wjakob";
    repo = "nanobind";
    rev = "v${version}";
    hash = "sha256-yQmRSs1W+onT1+I/GGYqsp7P8MlhomZ6sVl0Lxhr5e4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ python cmake ];

  cmakeFlags = [
    "-DNB_TEST=OFF"
  ];

  installPhase = ''
    ls -la $src
    mkdir -p $out/include $out/ext $out/src $out/cmake
    cp -r $src/include $out
    cp -r $src/cmake $out
    cp -r $src/src $out
    cp -r $src/ext $out
  '';


  meta = with lib; {
    description = "Small binding library that exposes C++ types in Python and vice versa";
    homepage = "https://github.com/wjakob/nanobind";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
