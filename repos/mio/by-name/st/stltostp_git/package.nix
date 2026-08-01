{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "stltostp_git";
  version = "unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "slugdev";
    repo = "stltostp";
    rev = "e083236";
    hash = "sha256-p0+h2J1V4cdTdYy9G7S1HI3ahxs/EN3A13Lf2PHyWfM=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Command line utility to convert stl files to STEP brep files";
    homepage = "https://github.com/slugdev/stltostp";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ ];
    mainProgram = "stltostp";
  };
}
