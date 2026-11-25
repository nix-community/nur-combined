{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "v${version}";
    hash = "sha256-zCKjjQ/RYc+BK68WJkTj8ieECtSArbt7cEZLQLTYt8U=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCPPSORT_BUILD_TESTING=OFF"
    "-DCPPSORT_BUILD_EXAMPLES=OFF"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Generic header-only C++14 sorting library.";
    homepage = "https://github.com/Morwenn/cpp-sort";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
