{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "${version}";
    hash = "sha256-AkObiVW0wFAbH4RW7Y7lw+kCM86Kl+Two67804rbUe4=";
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
