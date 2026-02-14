{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "v${version}";
    hash = "sha256-VoK//2X+sPS5SFFnZf9WF02x5wAbv04X0ghPy1Z6pOo=";
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
