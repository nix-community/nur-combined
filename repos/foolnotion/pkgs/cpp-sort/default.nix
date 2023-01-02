{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "${version}";
    sha256 = "sha256-AwKH4jAKpNSuuyEtvWoWpFtA0zXKBdr/9v42lePtT+k=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCPPSORT_BUILD_TESTING=OFF"
    "-DCPPSORT_BUILD_EXAMPLES=OFF"
  ];

  meta = with lib; {
    description = "Generic header-only C++14 sorting library.";
    homepage = "https://github.com/Morwenn/cpp-sort";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
