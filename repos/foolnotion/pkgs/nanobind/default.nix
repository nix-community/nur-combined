{ lib, stdenv, fetchFromGitHub, cmake, robin-map, python,
enableTesting ? false
}:

stdenv.mkDerivation rec {
  pname = "nanobind";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "wjakob";
    repo = "nanobind";
    rev = "v${version}";
    hash = "sha256-6swDqw7sEYOawQbNWD8VfSQoi+9wjhOhOOwPPkahDas=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ python cmake ];

  cmakeFlags = [
    "-DNB_TEST=${if enableTesting then "YES" else "NO"}"
  ];

  meta = with lib; {
    description = "Small binding library that exposes C++ types in Python and vice versa";
    homepage = "https://github.com/wjakob/nanobind";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
