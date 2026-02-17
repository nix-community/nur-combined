{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  name = "msd-lite";

  src = fetchFromGitHub {
    owner = "rozhuk-im";
    repo = "msd_lite";
    rev = "79a6c62c8fced6128a5e445ee110709b3b51bb78";
    sha256 = "sha256-OEpPlxJqsGrokyVvvACrZMV7wosY/RzFPBnqRr2lUIg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Multi stream daemon - lightweight daemon for streaming media";
    homepage = "https://github.com/rozhuk-im/msd_lite";
    license = licenses.bsd2;
    mainProgram = "msd_lite";
  };
}
