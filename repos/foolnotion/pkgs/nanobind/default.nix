{ lib, stdenv, fetchFromGitHub, cmake, robin-map, python,
enableTesting ? false
}:

stdenv.mkDerivation rec {
  pname = "nanobind";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "wjakob";
    repo = "nanobind";
    rev = "05cba0ef85ba2bb68aa115af4b74c30aa2aa7bec";
    sha256 = "sha256-LNL0vVBWPfq4XhfWfe1blfmkpkSEU8hlJ+S4aHo5v+M=";
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
