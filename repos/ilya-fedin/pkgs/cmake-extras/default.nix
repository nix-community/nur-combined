{ lib, stdenv, fetchFromGitLab, cmake }:

stdenv.mkDerivation {
  pname = "cmake-extras";
  version = "1.6";

  src = fetchFromGitLab {
    group = "ubports";
    owner = "core";
    repo = "cmake-extras";
    rev = "1.6";
    sha256 = "sha256-AY0KtWWGP8Kiu+shZCm4hDQfbyP+SRrurBLoyiawn8o=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A collection of add-ons for the CMake build tool.";
    homepage = "https://gitlab.com/ubports/core/cmake-extras";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = [ maintainers.ilya-fedin ];
  };
}
