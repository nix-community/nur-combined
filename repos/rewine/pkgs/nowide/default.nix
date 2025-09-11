{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
}:

stdenv.mkDerivation rec {
  pname = "nowide";
  version = "11.3.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "nowide";
    rev = "v${version}";
    hash = "sha256-Jik+rsc+NHLy+GfICGnkToZuNHI3b3ajbXO32tYo0Dk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
  ];

  meta = with lib; {
    description = "Boost.Nowide - Standard library functions with UTF-8 API on Windows";
    homepage = "https://github.com/boostorg/nowide";
    license = licenses.boost;
    maintainers = with maintainers; [ wineee ];
  };
}
