{ lib, mkDerivation, fetchFromGitHub, qmake }:
mkDerivation rec {
  name = "traceshark-unstable-2020-05-15";

  src = fetchFromGitHub {
    owner = "cunctator";
    repo = "traceshark";
    rev = "3c7fd7d17b7fb97e7176600b29e5d24b61231d65";
    sha256 = "01yq585chvyghqkpw123ln9dpp863ylqbribqy77dfw2bq1jm47a";
  };

  qmakeFlags = [ "CUSTOM_INSTALL_PREFIX=${placeholder "out"}" ];

  nativeBuildInputs = [ qmake ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "This is a tool for Linux kernel ftrace and perf events visualization";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
