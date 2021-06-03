{ lib, stdenv, fetchFromGitHub, autoreconfHook269, pkg-config, cairo, librsvg }:

stdenv.mkDerivation rec {
  pname = "smrender";
  version = "2021-03-15";

  src = fetchFromGitHub {
    owner = "rahra";
    repo = pname;
    rev = "3c146d1dcf28d59866598a3de924dcb8b119e6df";
    hash = "sha256-tgUoSrsZWAPDPnujiB69dgSdZtPUoO9VuMgwlDfEeN0=";
  };

  postPatch = ''
    substituteInPlace configure.ac \
      --replace "git log --oneline | wc -l" "echo 470"
  '';

  nativeBuildInputs = [ autoreconfHook269 pkg-config ];

  buildInputs = [ cairo librsvg ];

  meta = with lib; {
    description = "A powerful, flexible, and modular rule-based rendering engine for OSM data";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
